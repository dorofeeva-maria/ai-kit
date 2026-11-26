#!/usr/bin/env bash
# Test: workspace-sync.sh sync must not rebase a later part (<branch>-part-2) onto the base when
# the previous part exists only on origin. Run: bash tests/sync-chain.sh
set -eu
here=$(cd "$(dirname "$0")" && pwd)
sync="$here/../skills/sync/scripts/workspace-sync.sh"
t=$(mktemp -d)
trap 'rm -rf "$t"' EXIT
export GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@t GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@t
g() { git -c core.autocrlf=false "$@"; }

ws="$t/ws"
mkdir -p "$ws/.claude" "$ws/tasks/in-work/DEV-1" "$ws/worktrees/DEV-1"
printf '## Repos\n\n| folder | what | base | sync |\n|---|---|---|---|\n| app | x | develop | on |\n' > "$ws/.claude/kit-profile.md"

g init -q --bare -b develop "$t/origin.git"
g clone -q "$t/origin.git" "$ws/app" 2>/dev/null
cd "$ws/app"
g checkout -q -b develop
echo 0 > f0; g add f0; g commit -qm base; g push -q origin develop
g checkout -q -b feature/DEV-1-x
echo 1 > f1; g add f1; g commit -qm part1; g push -q origin feature/DEV-1-x
g checkout -q -b feature/DEV-1-x-part-2
echo 2 > f2; g add f2; g commit -qm part2; g push -q origin feature/DEV-1-x-part-2
g checkout -q develop
g worktree add -q "$ws/worktrees/DEV-1/app" feature/DEV-1-x-part-2
# part 1 has no tree; develop moves on
g checkout -q develop; echo 3 > f3; g add f3; g commit -qm news; g push -q origin develop

before=$(g -C "$ws/worktrees/DEV-1/app" rev-parse HEAD)
out=$(bash "$sync" sync --workspace "$ws" 2>&1) || true
after=$(g -C "$ws/worktrees/DEV-1/app" rev-parse HEAD)
echo "$out"
fail=0
[ "$before" = "$after" ] || { echo "FAIL: part 2 was rebased"; fail=1; }
case "$out" in *"a chain with origin/feature/DEV-1-x"*) ;; *) echo "FAIL: no chain note"; fail=1 ;; esac

# once part 1 is merged into develop, a plain rebase is fine again
g -C "$ws/app" checkout -q develop
g -C "$ws/app" merge -q --no-edit origin/feature/DEV-1-x
g -C "$ws/app" push -q origin develop
out=$(bash "$sync" sync --workspace "$ws" 2>&1) || true
case "$out" in *"rebased on origin/develop"*) ;; *) echo "$out"; echo "FAIL: merged part 1 still blocks"; fail=1 ;; esac
[ "$fail" = 0 ] && echo PASS
exit "$fail"
