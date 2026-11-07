#!/usr/bin/env bash
# Print a <details> Files block from `git diff --name-status` output on stdin.
# usage: git diff --name-status origin/main...HEAD | files-block.sh
set -euo pipefail

input=$(cat)

section() {
  local label="$1" pattern="$2" rows
  rows=$(printf '%s\n' "$input" \
    | awk -F'\t' -v p="$pattern" '$1 ~ p {print "- `" $NF "`"}')

  if [ -n "$rows" ]; then
    printf '%s:\n\n%s\n\n' "$label" "$rows"
  fi
}

echo "<details><summary>Files</summary>"
echo
section "New" '^A'
section "Changed" '^M'
section "Renamed" '^R'
section "Deleted" '^D'
echo "</details>"
