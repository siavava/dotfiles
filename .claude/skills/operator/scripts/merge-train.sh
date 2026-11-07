#!/usr/bin/env bash
# Squash-merge pull requests one at a time, each only when every check on its
# head commit has ended green, pinned to that commit. Stops at the first red
# check, conflict or timeout and says why.
#
# usage: REPO=owner/name MIN_CHECKS=<n> merge-train.sh <pr> [<pr> ...]
# MIN_CHECKS is the number of checks a full run shows on that repo, so a PR
# whose checks have not all registered yet is not merged early.
set -uo pipefail

repo="${REPO:?set REPO=owner/name}"
min="${MIN_CHECKS:-1}"
wait_s="${WAIT_SECONDS:-2700}"
log_dir="${LOG_DIR:-${TMPDIR:-/tmp}}"

state_of() {
  gh pr view "$1" --repo "$repo" \
    --json headRefOid,mergeable,state,title,statusCheckRollup \
    -q '[.headRefOid, .mergeable, .state, .title,
         ([.statusCheckRollup[] | (if (.conclusion // "") != "" then .conclusion
            elif (.status // "") != "" then .status else "NONE" end)]
          | join(","))] | @tsv'
}

for n in "$@"; do
  deadline=$((SECONDS + wait_s))

  while :; do
    IFS=$'\t' read -r sha mergeable state title checks < <(state_of "$n")

    if [ "$state" = "MERGED" ]; then
      echo "#$n already merged"
      continue 2
    fi

    pending=$(echo "$checks" | tr ',' '\n' \
      | grep -cE '^(NONE|PENDING|QUEUED|IN_PROGRESS|WAITING|REQUESTED|EXPECTED)$')
    red=$(echo "$checks" | tr ',' '\n' | grep . \
      | grep -cvE '^(SUCCESS|SKIPPED|NEUTRAL|NONE|PENDING|QUEUED|IN_PROGRESS|WAITING|REQUESTED|EXPECTED)$')
    total=$(echo "$checks" | tr ',' '\n' | grep -c .)

    if [ "$red" -gt 0 ]; then
      echo "#$n STOP: a check is red on ${sha:0:8}: $checks"
      exit 1
    fi

    if [ "$mergeable" = "CONFLICTING" ]; then
      echo "#$n STOP: conflicts with the base"
      exit 2
    fi

    if [ "$pending" -eq 0 ] && [ "$total" -ge "$min" ] \
      && [ "$mergeable" = "MERGEABLE" ]; then
      break
    fi

    if [ $SECONDS -ge $deadline ]; then
      echo "#$n STOP: timed out; checks: $checks; mergeable: $mergeable"
      exit 3
    fi

    command sleep 30
  done

  echo "#$n green on ${sha:0:8}: $checks"

  timeout 120 gh pr merge "$n" --repo "$repo" --squash \
    --match-head-commit "$sha" --subject "$title (#$n)" \
    > "$log_dir/merge-$n.log" 2>&1
  rc=$?

  merged=$(gh pr view "$n" --repo "$repo" --json state,mergeCommit \
    -q '.state + " " + (.mergeCommit.oid // "")')
  echo "#$n merge exit $rc -> $merged"

  case "$merged" in
    MERGED*) ;;
    *)
      echo "#$n STOP: not merged: $(tail -2 "$log_dir/merge-$n.log")"
      exit 4
      ;;
  esac

  msg=$(gh api "repos/$repo/commits/${merged#MERGED }" -q .commit.message)
  echo "#$n message attribution lines: $(echo "$msg" | grep -ciE 'co-authored-by|generated with')"

  command sleep 8
done

echo "train done"
