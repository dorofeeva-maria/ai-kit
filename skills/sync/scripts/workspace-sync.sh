#!/usr/bin/env bash
# Sync a kit workspace: refresh the bases of its repos, rebase the trees of active tasks, and say
# what came into each base since the last sync.
#
#   workspace-sync.sh status   [--workspace <dir>]   # read only, no network
#   workspace-sync.sh fetch    [--workspace <dir>]   # + git fetch, and what came since the last sync
#   workspace-sync.sh sync     [--workspace <dir>]   # + fast-forward clean bases, rebase task trees
#   workspace-sync.sh hook-start                     # plugin SessionStart hook: the fetch report
#   workspace-sync.sh hook-prompt                    # plugin UserPromptSubmit hook: reminders
#
# The workspace is the nearest folder upward with .claude/kit-profile.md. The hooks print nothing
# outside a workspace or when no repo in its `## Repos` table has sync on.
#
# Profile, `## Repos`: a table `| folder | what it is | base | sync |`; sync is on when its cell
# starts with "on". Profile, `## Sync`, optional bullets:
#   - adapter <folder>: <command>   the command handles that repo (and its trees) instead of this
#                                   script; it is run from the workspace root with the mode as its
#                                   last argument and prints report rows (8 fields joined by "|")
#                                   and any lines for the "what came" section; nonzero = failed
#   - after <folder>: <command>     run in the base checkout after it was refreshed on its base
#                                   branch, mode as its last argument; its output joins the note
#   - submodules: ignore            submodule changes do not make a checkout dirty
#   - reminder: <hours>             how old a sync may get before the prompt hook reminds (3)
#   - instructions: <paths>         files whose change the digest names (AGENTS.md CLAUDE.md .claude docs/agents)
# Commands from the profile run in the workspace's own shell: write them as you would type them.
#
# Task trees are worktrees/<KEY>/<repo>/. A tree is rebased in sync mode only when its task folder
# is tasks/in-work/<KEY> or tasks/review/<KEY>, it is on a branch, nothing is uncommitted, its
# remote branch holds no commit it lacks, and it shares no commits with another task tree of the
# same repo, and it is not a later part (`<branch>-part-N`) of an unmerged previous part on origin,
# even one with no tree (a chain is rebased in order by the session). A conflict aborts the rebase and names
# the files. A tree with uncommitted changes is queued: the prompt hook says when it is clean.
set -u

usage() {
  echo "usage: workspace-sync.sh status|fetch|sync [--workspace <dir>] | hook-start | hook-prompt" >&2
  exit 2
}

[ "$#" -ge 1 ] || usage
mode=$1
shift
case "$mode" in status|fetch|sync|hook-start|hook-prompt) ;; *) usage ;; esac
ws=
while [ "$#" -gt 0 ]; do
  case "$1" in
    --workspace) [ "$#" -ge 2 ] || usage; ws=$2; shift 2 ;;
    *) usage ;;
  esac
done

here=$(cd "$(dirname "$0")" && pwd)
report="$here/../../task/scripts/repo-report.sh"
[ -f "$report" ] || { echo "ai-kit: missing $report" >&2; exit 1; }

find_ws() {
  local d=$1 p
  while [ -n "$d" ]; do
    [ -f "$d/.claude/kit-profile.md" ] && { printf '%s\n' "$d"; return 0; }
    p=$(dirname "$d")
    [ "$p" = "$d" ] && return 1
    d=$p
  done
  return 1
}

hook=0
case "$mode" in hook-*) hook=1 ;; esac
if [ -z "$ws" ]; then
  ws=$(find_ws "${CLAUDE_PROJECT_DIR:-$PWD}") || { [ "$hook" = 1 ] && exit 0; echo "No .claude/kit-profile.md here or above." >&2; exit 1; }
fi
ws=$(cd "$ws" && pwd) || exit 1
profile="$ws/.claude/kit-profile.md"
[ -f "$profile" ] || { [ "$hook" = 1 ] && exit 0; echo "No profile at $profile" >&2; exit 1; }

# --- profile -------------------------------------------------------------------------------------

section() { # $1 = heading text after "## "
  awk -v h="## $1" '
    /^## / { on = (tolower($0) == tolower(h)) || (index(tolower($0), tolower(h) " ") == 1); next }
    on' "$profile"
}

# folder|base|sync for every row of the Repos table (header and separator rows dropped).
repos=$(section Repos | awk -F'|' '
  /^[[:space:]]*\|/ {
    f = $2; b = $4; s = $5
    gsub(/`/, "", f); gsub(/`/, "", b)
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", f); gsub(/^[[:space:]]+|[[:space:]]+$/, "", b); gsub(/^[[:space:]]+|[[:space:]]+$/, "", s)
    if (f == "" || f ~ /^:?-+:?$/ || b ~ /^:?-+:?$/) next
    if (tolower(s) !~ /^on/) next
    if (b == "—" || b == "–" || b == "-") b = ""
    print f "|" b
  }' | awk -F'|' 'NR > 0 && tolower($1) != "folder" && tolower($1) != "папка"')
[ -n "$repos" ] || { [ "$hook" = 1 ] && exit 0; echo "No repo in the profile's Repos table has sync on." >&2; exit 1; }

sync_opts=$(section Sync | sed -n 's/^[[:space:]]*-[[:space:]]*//p' | tr -d '`')
opt() { # $1 = key → value of "- key: value"
  printf '%s\n' "$sync_opts" | awk -v k="$1" 'tolower($0) ~ "^" k ":" { sub(/^[^:]*:[[:space:]]*/, ""); print; exit }'
}
repo_cmd() { # $1 = adapter|after, $2 = folder
  printf '%s\n' "$sync_opts" | awk -v k="$1 $2:" 'index($0, k) == 1 { print substr($0, length(k) + 1); exit }' | sed 's/^[[:space:]]*//'
}
base_of() { printf '%s\n' "$repos" | awk -F'|' -v r="$1" '$1 == r { print $2; exit }'; }

submodules=()
case "$(opt submodules)" in ignore*) submodules=(--ignore-submodules) ;; esac
reminder=$(opt reminder | tr -dc '0-9')
[ -n "$reminder" ] || reminder=3
instructions=$(opt instructions)
[ -n "$instructions" ] || instructions="AGENTS.md CLAUDE.md .claude docs/agents"

if gitdir=$(git -C "$ws" rev-parse --absolute-git-dir 2>/dev/null); then
  state="$gitdir/ai-kit"
else
  state="${XDG_STATE_HOME:-$HOME/.local/state}/ai-kit/$(printf '%s' "$ws" | tr -c 'A-Za-z0-9._-' '_')"
fi
mkdir -p "$state" 2>/dev/null
pending="$state/rebase-pending"
bases_state="$state/sync-bases"
last_sync="$state/last-sync"

# --- the prompt hook: cheap, local, no network ---------------------------------------------------

if [ "$mode" = hook-prompt ]; then
  last=
  [ -f "$last_sync" ] && read -r last < "$last_sync"
  now=$(date +%s)
  if ! [[ ${last:-} =~ ^[0-9]+$ ]]; then
    echo "ai-kit: no workspace sync is recorded. Run /ai-kit:sync before starting work."
  elif [ $((now - last)) -ge $((reminder * 3600)) ]; then
    echo "ai-kit: the last workspace sync was $(((now - last) / 3600)) h ago. Run /ai-kit:sync before starting work."
  fi
  if [ -s "$pending" ]; then
    keep=
    while IFS= read -r tree; do
      [ -n "$tree" ] && [ -e "$ws/$tree/.git" ] || continue
      keep="$keep$tree"$'\n'
      repo=${tree##*/}
      base=$(base_of "$repo")
      [ -n "$base" ] || continue
      [ -z "$(git -C "$ws/$tree" status --porcelain "${submodules[@]/--ignore-submodules/--ignore-submodules=all}" 2>/dev/null)" ] || continue
      behind=$(git -C "$ws/$tree" rev-list --count "HEAD..origin/$base" 2>/dev/null) || continue
      [ "${behind:-0}" -gt 0 ] && echo "ai-kit: $tree is committed now and $behind behind origin/$base. Rebase it now: run /ai-kit:sync."
    done < "$pending"
    printf '%s' "$keep" > "$pending"
  fi
  exit 0
fi

[ "$mode" = hook-start ] && mode=fetch

# --- reports -------------------------------------------------------------------------------------

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
key_of() { printf '%s' "$1" | tr '/:' '__'; }

base_row() { # $1 = folder, $2 = base
  local folder=$1 base=$2 f="$tmp/$(key_of "$1")" row rc after extra branch note
  if [ ! -e "$ws/$folder/.git" ]; then
    echo "$folder|-|${base:--}|-|-|-|-|not on this device" > "$f"
    return
  fi
  local args=("$folder" "$mode" "${submodules[@]}")
  [ -z "$base" ] || args+=(--base "$base")
  row=$(cd "$ws/$folder" && bash "$report" "${args[@]}" 2>/dev/null); rc=$?
  [ -n "$row" ] || { row="$folder|?|?|-|-|-|-|no answer"; rc=1; }
  IFS='|' read -r _ branch _ _ _ _ _ note <<< "$row"
  after=$(repo_cmd after "$folder")
  if [ -n "$after" ] && [ "$mode" = sync ] && [ "$rc" = 0 ] && [ "$branch" = "${base:-$branch}" ] &&
     { [ -z "$note" ] || [ "$note" = fast-forwarded ]; }; then
    extra=$(cd "$ws/$folder" && AI_KIT_WORKSPACE="$ws" bash -c "$after \"\$1\"" _ "$mode" 2>&1) || rc=1
    [ -z "$extra" ] || row="$row${note:+; }$(printf '%s' "$extra" | tr '\n' ' ')"
  fi
  printf '%s\n' "$row" > "$f"
  [ "$rc" = 0 ] || touch "$f.failed"
}

adapter_rows() { # $1 = folder, $2 = command
  local f="$tmp/$(key_of "$1")" out rc
  out=$(cd "$ws" && AI_KIT_WORKSPACE="$ws" AI_KIT_REPORT="$report" bash -c "$2 \"\$1\"" _ "$mode" 2>&1); rc=$?
  printf '%s\n' "$out" | awk -F'|' 'NF == 8' > "$f"
  printf '%s\n' "$out" | awk -F'|' 'NF != 8 && NF > 0' > "$f.incoming"
  [ -s "$f" ] || echo "$1|?|?|-|-|-|-|adapter gave no row" > "$f"
  [ "$rc" = 0 ] || touch "$f.failed"
}

order=
while IFS='|' read -r folder base; do
  order="$order $folder"
  cmd=$(repo_cmd adapter "$folder")
  if [ -n "$cmd" ]; then
    adapter_rows "$folder" "$cmd" &
  else
    base_row "$folder" "$base" &
  fi
done <<< "$repos"
wait

# --- task trees ----------------------------------------------------------------------------------

active() { [ -d "$ws/tasks/in-work/$1" ] || [ -d "$ws/tasks/review/$1" ]; }
pending_set() { # $1 = add|drop, $2 = tree
  local rest
  rest=$(grep -vxF -- "$2" "$pending" 2>/dev/null)
  { [ -z "$rest" ] || printf '%s\n' "$rest"; [ "$1" = drop ] || printf '%s\n' "$2"; } > "$pending.new" && mv "$pending.new" "$pending"
}

trees=
for d in "$ws"/worktrees/*/*/; do
  [ -f "${d}.git" ] || continue
  d=${d%/}
  tree=${d#"$ws/"}
  repo=${tree##*/}
  printf '%s\n' "$repos" | grep -q "^$repo|" || continue
  [ -z "$(repo_cmd adapter "$repo")" ] || continue
  trees="$trees $tree"
done

# Commits each tree holds beyond its base, to find chains before anything moves.
for tree in $trees; do
  repo=${tree##*/}
  git -C "$ws/$tree" rev-list "HEAD" --not "origin/$(base_of "$repo")" 2>/dev/null | sort > "$tmp/own-$(key_of "$tree")"
done

prev_part() { # $1 = tree, $2 = branch, $3 = base → origin/<previous part> when it is an unmerged part of a chain
  local tree=$1 branch=$2 base=$3 stem n prev
  [[ $branch =~ ^(.+)-part-([0-9]+)$ ]] || return 1
  stem=${BASH_REMATCH[1]}
  n=${BASH_REMATCH[2]}
  if [ "$n" -le 2 ]; then prev=$stem; else prev="$stem-part-$((n - 1))"; fi
  git -C "$ws/$tree" rev-parse -q --verify "refs/remotes/origin/$prev^{commit}" >/dev/null 2>&1 || return 1
  # not merged into the base, and either under this branch or copied into it
  [ -n "$(git -C "$ws/$tree" rev-list -n 1 "origin/$prev" --not "origin/$base" 2>/dev/null)" ] || return 1
  git -C "$ws/$tree" merge-base --is-ancestor "origin/$prev" HEAD 2>/dev/null ||
    [ -n "$(git -C "$ws/$tree" cherry HEAD "origin/$prev" 2>/dev/null | grep '^-' | head -n 1)" ] || return 1
  printf '%s\n' "origin/$prev"
}

tree_row() { # $1 = tree
  local tree=$1 repo=${1##*/} key base f row rc branch behind ahead dirty range note upstream pushed foreign other files
  key=$(basename "$(dirname "$tree")")
  base=$(base_of "$repo")
  f="$tmp/$(key_of "$tree")"
  local args=("$tree" status "${submodules[@]}")
  [ -z "$base" ] || args+=(--base "$base")
  row=$(cd "$ws/$tree" && bash "$report" "${args[@]}" 2>/dev/null); rc=$?
  [ -n "$row" ] || { echo "$tree|?|?|-|-|-|-|no answer" > "$f"; touch "$f.failed"; return; }
  IFS='|' read -r _ branch base behind ahead dirty range note <<< "$row"
  if [ "$mode" = sync ] && [ "$rc" = 0 ] && [ -z "$note" ]; then
    if [ "$behind" = 0 ]; then
      pending_set drop "$tree"
    elif ! active "$key"; then
      note="behind; task not in work or review: left as is"
    elif [ "${branch#(detached}" != "$branch" ]; then
      note="behind; detached: left as is"
    elif [ "$dirty" != 0 ]; then
      pending_set add "$tree"
      note="waits: uncommitted changes; rebase once they are committed"
    else
      # The pushed copy is origin/<the same branch>; a tracked base (origin/<base>) is not one.
      upstream=
      pushed=$(git -C "$ws/$tree" rev-parse -q --verify "refs/remotes/origin/$branch^{commit}" 2>/dev/null) && upstream="origin/$branch"
      foreign=0
      [ -z "$upstream" ] || foreign=$(git -C "$ws/$tree" rev-list --count "HEAD..$pushed" 2>/dev/null || echo 0)
      other=
      if [ -s "$tmp/own-$(key_of "$tree")" ]; then
        for t in $trees; do
          [ "$t" != "$tree" ] && [ "${t##*/}" = "$repo" ] || continue
          if [ -n "$(comm -12 "$tmp/own-$(key_of "$tree")" "$tmp/own-$(key_of "$t")" | head -n 1)" ]; then other=$t; break; fi
        done
      fi
      [ -n "$other" ] || other=$(prev_part "$tree" "$branch" "$base")
      if [ "$foreign" != 0 ]; then
        note="behind; $upstream has $foreign commit(s) this tree lacks: ask the human"
      elif [ -n "$other" ]; then
        note="behind; a chain with $other: rebase the chain in order"
      elif GIT_EDITOR=true git -C "$ws/$tree" rebase -q "origin/$base" >/dev/null 2>&1; then
        pending_set drop "$tree"
        note="rebased on origin/$base"
        if [ -n "$upstream" ]; then
          if git -C "$ws/$tree" push -q --force-with-lease="refs/heads/$branch:$pushed" origin "HEAD:refs/heads/$branch" >/dev/null 2>&1; then
            note="$note, pushed"
          else
            note="$note; push failed"
            rc=1
          fi
        fi
      else
        files=$(git -C "$ws/$tree" diff --name-only --diff-filter=U | tr '\n' ' ')
        git -C "$ws/$tree" rebase --abort >/dev/null 2>&1
        note="conflict, rebase aborted: ${files% }"
      fi
    fi
  fi
  echo "$tree|$branch|$base|$behind|$ahead|$dirty|$range|$note" > "$f"
  [ "$rc" = 0 ] || touch "$f.failed"
}

for tree in $trees; do tree_row "$tree"; done

# --- the table -----------------------------------------------------------------------------------

stale=0
printf '%-34s %-40s %-9s %6s %6s %6s  %s\n' REPO BRANCH BASE BEHIND AHEAD DIRTY NOTE
for name in $order $trees; do
  for f in "$tmp/$(key_of "$name")"; do
    [ -f "$f" ] || continue
    while IFS='|' read -r n branch base behind ahead dirty range note; do
      printf '%-34s %-40s %-9s %6s %6s %6s  %s\n' "$n" "$branch" "$base" "$behind" "$ahead" "$dirty" "$note"
      case "$behind" in ''|-|0) ;; *) case "$note" in fast-forwarded|rebased*) ;; *) stale=1 ;; esac ;; esac
    done < "$f"
  done
done

# --- what came into each base since the last sync ------------------------------------------------

if [ "$mode" != status ]; then
  echo
  echo "WHAT CAME SINCE THE LAST SYNC"
  moved=0
  newstate=
  for folder in $order; do
    f="$tmp/$(key_of "$folder")"
    if [ -s "$f.incoming" ]; then
      cat "$f.incoming"
      moved=1
      continue
    fi
    [ -z "$(repo_cmd adapter "$folder")" ] || continue
    [ -e "$ws/$folder/.git" ] || continue
    base=$(base_of "$folder")
    ref="origin/${base:-HEAD}"
    new=$(git -C "$ws/$folder" rev-parse -q --verify "$ref^{commit}") || { echo "$folder: no $ref"; continue; }
    old=$(awk -v n="$folder" '$1 == n { print $2 }' "$bases_state" 2>/dev/null)
    git -C "$ws/$folder" cat-file -e "${old:-x}^{commit}" 2>/dev/null || old=$(git -C "$ws/$folder" rev-parse -q --verify "$ref@{1}^{commit}")
    [ -f "$f.failed" ] || newstate="$newstate$folder $new"$'\n'
    [ -n "$old" ] && [ "$old" != "$new" ] || continue
    if ! git -C "$ws/$folder" merge-base --is-ancestor "$old" "$new" 2>/dev/null; then
      echo "$folder: the history of $ref was rewritten; the range is approximate"
      old=$(git -C "$ws/$folder" merge-base "$old" "$new") || continue
    fi
    count=$(git -C "$ws/$folder" rev-list --no-merges --count "$old..$new")
    [ "$count" -gt 0 ] || continue
    moved=1
    echo "$folder: ${old:0:10}..${new:0:10}, $count commit(s)"
    git -C "$ws/$folder" log --no-merges --format='  %h %s' "$old..$new" | head -n 60
    [ "$count" -le 60 ] || echo "  … and $((count - 60)) more"
    # shellcheck disable=SC2086
    files=$(git -C "$ws/$folder" diff --name-only "$old" "$new" -- $instructions)
    [ -z "$files" ] || { echo "  instruction files changed:"; printf '%s\n' "$files" | sed 's/^/    /'; }
  done
  [ "$moved" = 1 ] || echo "Nothing new."
  if [ "$mode" = sync ]; then
    {
      printf '%s' "$newstate"
      awk 'NF == 2' "$bases_state" 2>/dev/null | while read -r n s; do
        case $'\n'"$newstate" in *$'\n'"$n "*) ;; *) echo "$n $s" ;; esac
      done
    } > "$bases_state.new" && mv "$bases_state.new" "$bases_state"
  fi
fi

failed=0
compgen -G "$tmp/*.failed" >/dev/null && failed=1
if [ "$failed" = 1 ]; then
  echo
  echo "Incomplete: see the notes in the table."
elif [ "$mode" = sync ]; then
  date +%s > "$last_sync"
fi
if [ "$mode" = fetch ] && [ "$stale" = 1 ]; then
  echo
  echo "Something is behind its base. Run /ai-kit:sync before starting work."
fi
exit "$failed"
