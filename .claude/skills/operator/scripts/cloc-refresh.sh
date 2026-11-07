#!/usr/bin/env bash
# Refresh one checkout's .cloc the way the monorepo's scripts/cloc.sh does:
# two header lines, then cloc over the git-tracked tree with lockfiles matched
# out by name. Run it in a nested checkout that has no monorepo root above it.
#
# usage: cloc-refresh.sh <checkout> <name>
set -euo pipefail

repo="${1:?checkout path}"
name="${2:?repo name, as the header prints it}"
readonly GENERATED='^(bun\.lock|package-lock\.json|yarn\.lock|pnpm-lock\.yaml|Cargo\.lock)$'

cd "$repo"

{
  echo "# $name — source inventory"
  echo "# Regenerate with: make cloc   (never edit by hand)"
  echo
  cloc --vcs=git --quiet --hide-rate --not-match-f="$GENERATED" .
} > .cloc

echo "wrote $name/.cloc"
