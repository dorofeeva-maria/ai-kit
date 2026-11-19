#!/usr/bin/env bash
# Report name|branch|base|behind|ahead|dirty|range|note. Counts and range are
# from before any fast-forward so the caller can summarize incoming commits.
usage() {
  echo "Usage: repo-report.sh <name> <status|fetch|sync> [--remote <name>] [--base <branch>] [--ignore-submodules]" >&2
  exit 2
}

[ "$#" -ge 2 ] || usage
name=$1
mode=$2
[ -n "$name" ] || usage
case "$mode" in status|fetch|sync) ;; *) usage ;; esac
shift 2
remote=origin
base=
submodules=none
while [ "$#" -gt 0 ]; do
  case "$1" in
    --remote) [ "$#" -ge 2 ] && [ -n "$2" ] || usage; remote=$2; shift 2 ;;
    --base) [ "$#" -ge 2 ] && [ -n "$2" ] || usage; base=$2; shift 2 ;;
    --ignore-submodules) submodules=all; shift ;;
    *) usage ;;
  esac
done

row() {
  printf '%s|%s|%s|%s|%s|%s|%s|%s\n' "${name//|/%7C}" "${1//|/%7C}" "${2//|/%7C}" "$3" "$4" "$5" "$6" "$7"
}
if ! git rev-parse --git-dir >/dev/null 2>&1; then
  row - - - - - - "not a Git repository"
  exit 1
fi

note=
result=0
if [ "$mode" != status ]; then
  ssh_command=${GIT_SSH_COMMAND:-$(git config --get core.sshCommand)}
  if command -v timeout >/dev/null 2>&1; then
    limit=(timeout 60)
  else
    limit=()
  fi
  if ! GIT_TERMINAL_PROMPT=0 GIT_SSH_COMMAND="${ssh_command:-ssh} -o BatchMode=yes -o ConnectTimeout=15" \
    "${limit[@]}" git fetch -q --prune -- "$remote" >&2; then
    note="fetch failed"
    result=1
  fi
fi

if [ -n "$base" ]; then
  base_ref="refs/remotes/$remote/$base"
else
  base_ref=$(git symbolic-ref -q "refs/remotes/$remote/HEAD")
  base=${base_ref#"refs/remotes/$remote/"}
fi

branch=$(git symbolic-ref -q HEAD)
branch=${branch#refs/heads/}
if ! head_commit=$(git rev-parse -q --verify 'HEAD^{commit}'); then
  row "${branch:--}" "${base:--}" - - - - "${note:+$note; }no HEAD commit"
  exit 1
fi
[ -n "$branch" ] || branch="(detached $(git rev-parse --short "$head_commit"))"
if [ -z "$base_ref" ] || ! base_commit=$(git rev-parse -q --verify "$base_ref^{commit}"); then
  row "$branch" "${base:--}" - - - - "${note:+$note; }base branch unavailable"
  exit 1
fi

if ! changes=$(GIT_OPTIONAL_LOCKS=0 git status --porcelain --untracked-files=normal "--ignore-submodules=$submodules"); then
  row "$branch" "$base" - - - - "${note:+$note; }git status failed"
  exit 1
fi
dirty=0
if [ -n "$changes" ]; then
  dirty=$(printf '%s\n' "$changes" | wc -l | tr -d ' ')
fi
if ! counts=$(git rev-list --left-right --count "$head_commit...$base_commit"); then
  row "$branch" "$base" - - "$dirty" - "${note:+$note; }commit counts unavailable"
  exit 1
fi
read -r ahead behind <<< "$counts"
range=-
if [ "$behind" -gt 0 ]; then
  common=$(git merge-base "$head_commit" "$base_commit") || common=
  if [ -n "$common" ]; then
    range="${common:0:10}..${base_commit:0:10}"
  fi
fi

for marker in rebase-merge rebase-apply MERGE_HEAD CHERRY_PICK_HEAD REVERT_HEAD BISECT_START sequencer; do
  if [ -e "$(git rev-parse --git-path "$marker")" ]; then
    note="${note:+$note; }Git operation in progress"
    break
  fi
done

if [ "$mode" = sync ] && [ "$behind" -gt 0 ] && [ -z "$note" ]; then
  if [ "$branch" != "$base" ]; then
    note="skipped: checkout is not on the base branch"
  elif [ "$dirty" -ne 0 ]; then
    note="skipped: checkout has changes"
  elif [ "$ahead" -ne 0 ] || [ "$range" = - ]; then
    note="skipped: checkout has diverged"
  elif git -c submodule.recurse=false merge -q --ff-only "$base_commit" >&2; then
    note="fast-forwarded"
  else
    note="fast-forward failed"
    result=1
  fi
fi

row "$branch" "$base" "$behind" "$ahead" "$dirty" "$range" "$note"
exit "$result"

