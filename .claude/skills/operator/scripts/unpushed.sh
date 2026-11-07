#!/usr/bin/env bash
# List every checkout under a worktrees directory that has commits ahead of
# its remote's default branch, commits its upstream lacks, or a dirty tree.
# Prints nothing for checkouts with nothing to land.
#
# usage: unpushed.sh <worktrees-dir> [<nested checkout name> ...]
# Default nested names: platform server core cli e2e mac coming-soon docs.
set -uo pipefail

root="${1:?worktrees dir}"
shift
names=("$@")
if [ "${#names[@]}" -eq 0 ]; then
  names=(platform server core cli e2e mac coming-soon docs literal-blog literal-landing)
fi

for d in "$root"/*/; do
  for sub in "${names[@]}"; do
    r="$d$sub"

    if [ ! -d "$r/.git" ] && [ ! -f "$r/.git" ]; then
      continue
    fi

    cd "$r" 2>/dev/null || continue
    git fetch -q origin 2>/dev/null
    b=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    def=$(git symbolic-ref -q --short refs/remotes/origin/HEAD 2>/dev/null \
      || echo origin/main)
    ahead=$(git rev-list --count "$def"..HEAD 2>/dev/null)
    up=$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null)
    unpushed="-"

    if [ -n "$up" ]; then
      unpushed=$(git rev-list --count "$up"..HEAD 2>/dev/null)
    fi

    dirty=$(git status --short 2>/dev/null | wc -l | tr -d ' ')

    if [ "$unpushed" = "0" ] && [ "$dirty" = "0" ]; then
      continue
    fi

    if [ "$unpushed" = "-" ] && [ "$ahead" = "0" ] && [ "$dirty" = "0" ]; then
      continue
    fi

    echo "$(basename "$d")/$sub $b ahead-of-main=$ahead unpushed=$unpushed dirty=$dirty"
  done
done
