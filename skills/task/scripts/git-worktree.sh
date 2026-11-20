#!/usr/bin/env bash
# Run from a checkout of the repository. Resolve base refs in that checkout.
usage() {
  cat >&2 <<'USAGE'
Usage: git-worktree.sh add <path> <branch> [<start-ref>] [--remote <name>]
       git-worktree.sh merged <path> <base-ref> [--exclude-no-commits]
       git-worktree.sh remove <path> <base-ref>
       git-worktree.sh release <path> <remote>
USAGE
  exit 2
}

merged() {
  local path=$1 base=$2 exclude_no_commits=$3
  local head_commit base_commit base_tree merged_tree ahead common target_common
  common=$(git rev-parse --path-format=absolute --git-common-dir) || return 2
  target_common=$(git -C "$path" rev-parse --path-format=absolute --git-common-dir) || return 2
  [ "$common" = "$target_common" ] || return 2
  head_commit=$(git -C "$path" rev-parse -q --verify 'HEAD^{commit}') || return 2
  base_commit=$(git rev-parse -q --verify --end-of-options "$base^{commit}") || return 2
  if [ "$exclude_no_commits" = yes ]; then
    ahead=$(git -C "$path" rev-list --count "$base_commit..$head_commit") || return 2
    [ "$ahead" -gt 0 ] || return 1
  fi
  git -C "$path" merge-base --is-ancestor "$head_commit" "$base_commit" && return 0
  base_tree=$(git -C "$path" rev-parse "$base_commit^{tree}") || return 2
  merged_tree=$(git -C "$path" merge-tree --write-tree "$base_commit" "$head_commit" 2>/dev/null) || return 1
  [ "$merged_tree" = "$base_tree" ]
}

cmd=${1:-}
[ "$#" -ge 3 ] || usage
path=$2
value=$3
[ -n "$path" ] && [ -n "$value" ] || usage
shift 3
case "$cmd" in
  add)
    branch=$value
    remote=origin
    start=
    if [ "$#" -gt 0 ] && [ "$1" != --remote ]; then
      start=$1
      shift
    fi
    if [ "$#" -gt 0 ]; then
      [ "$#" -eq 2 ] && [ "$1" = --remote ] && [ -n "$2" ] || usage
      remote=$2
    fi
    if ! git check-ref-format --branch "$branch" >/dev/null 2>&1 || [[ "$branch" == @\{* ]]; then
      echo "Invalid worktree branch: $branch" >&2
      exit 2
    fi
    local_ref="refs/heads/$branch"
    remote_ref="refs/remotes/$remote/$branch"
    if git show-ref --verify --quiet "$local_ref"; then
      git worktree add -q -- "$path" "$branch"
    elif git show-ref --verify --quiet "$remote_ref"; then
      git worktree add -q --track -b "$branch" -- "$path" "$remote_ref"
    else
      [ -n "$start" ] || start=$(git symbolic-ref -q "refs/remotes/$remote/HEAD")
      if [ -z "$start" ]; then
        echo "No start ref and no default branch for remote $remote" >&2
        exit 1
      fi
      start_commit=$(git rev-parse -q --verify --end-of-options "$start^{commit}") || {
        echo "Invalid worktree start ref: $start" >&2
        exit 1
      }
      git worktree add -q --no-track -b "$branch" -- "$path" "$start_commit"
    fi
    ;;
  merged)
    exclude_no_commits=no
    if [ "$#" -gt 0 ]; then
      [ "$#" -eq 1 ] && [ "$1" = --exclude-no-commits ] || usage
      exclude_no_commits=yes
    fi
    merged "$path" "$value" "$exclude_no_commits"
    ;;
  remove)
    [ "$#" -eq 0 ] || usage
    if [ ! -e "$path/.git" ] || [ -d "$path/.git" ]; then
      echo "Expected a linked worktree: $path" >&2
      exit 1
    fi
    target=$(cd -- "$path" && pwd -P) || exit 1
    prefix=$(git -C "$target" rev-parse --show-prefix) || exit 1
    if [ -n "$prefix" ]; then
      echo "Expected the root of a linked worktree: $target" >&2
      exit 1
    fi
    if ! merged "$target" "$value" no; then
      echo "Worktree has commits missing from $value or Git could not compare them: $target" >&2
      exit 1
    fi
    # Git checks the worktree's registration and refuses dirty or locked trees.
    git worktree remove -- "$target"
    ;;
  release)
    # The task no longer needs its tree (moved to review or done). Removes the tree when nothing
    # would be lost: no uncommitted change, and every commit of its branch is on the remote branch
    # or already in the remote's default branch. The local branch stays. Prints one line.
    [ "$#" -eq 0 ] || usage
    remote=$value
    if [ ! -e "$path/.git" ] || [ -d "$path/.git" ]; then
      echo "kept|$path|not a linked worktree"; exit 1
    fi
    target=$(cd -- "$path" && pwd -P) || exit 1
    branch=$(git -C "$target" symbolic-ref -q --short HEAD) || branch=
    if ! changes=$(git -C "$target" status --porcelain --ignore-submodules=all); then
      echo "kept|$target|git status failed"; exit 1
    fi
    [ -z "$changes" ] || { echo "kept|$target|$(printf '%s
' "$changes" | wc -l | tr -d ' ') uncommitted change(s)"; exit 1; }
    pushed=
    [ -z "$branch" ] || pushed=$(git -C "$target" rev-parse -q --verify "refs/remotes/$remote/$branch^{commit}")
    if [ -n "$pushed" ]; then
      ahead=$(git -C "$target" rev-list --count "$pushed..HEAD") || exit 1
      [ "$ahead" = 0 ] || { echo "kept|$target|$ahead commit(s) not pushed to $remote/$branch"; exit 1; }
    else
      default=$(git -C "$target" symbolic-ref -q "refs/remotes/$remote/HEAD") || default=
      if [ -z "$default" ] || ! (cd -- "$target" && merged "$target" "$default" no); then
        echo "kept|$target|branch not on $remote and not in its default branch"; exit 1
      fi
    fi
    main=$(dirname "$(git -C "$target" rev-parse --path-format=absolute --git-common-dir)")
    # A dependency folder linked from another checkout: drop the link only, never its target.
    for link in node_modules vendor; do
      [ -L "$target/$link" ] || continue
      if command -v cygpath >/dev/null 2>&1; then
        cmd //c rmdir "$(cygpath -w "$target/$link")" >/dev/null 2>&1 || rm -f -- "$target/$link"
      else
        rm -f -- "$target/$link"
      fi
    done
    git -C "$main" worktree remove --force -- "$target" >/dev/null 2>&1 || { echo "kept|$target|git could not remove it"; exit 1; }
    rmdir -- "$(dirname "$target")" 2>/dev/null
    echo "removed|$target|${branch:-detached} stays as a local branch"
    ;;
  *) usage ;;
esac

