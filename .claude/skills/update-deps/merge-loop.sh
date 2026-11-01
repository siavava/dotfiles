#!/bin/bash
# Serial Dependabot merge loop. Merges the given PRs in order; after each merge the
# rest usually turn CONFLICTING on the lockfile, so it asks Dependabot to rebase
# (once per head SHA) and waits for the required checks to pass before merging.
#
# usage: merge-loop.sh [-c check1,check2] [-t "trailer line"] "N|subject" ["N|subject" ...]
#   -c  comma-separated names of the checks that must be SUCCESS (statusCheckRollup
#       .name for GitHub Actions, .context for commit statuses). Default: "check".
#   -t  squash body, normally a single Co-authored-by trailer. Default: empty body.
# Run from inside the repository. Needs gh with merge rights. Stops at the first
# PR whose checks fail or that cannot be merged; exit code 2 = red checks, 3 = other.
set -u
checks="check"; trailer=""
while getopts "c:t:" opt; do
  case $opt in c) checks=$OPTARG ;; t) trailer=$OPTARG ;; *) exit 1 ;; esac
done
shift $((OPTIND - 1))
[ $# -gt 0 ] || { echo "usage: merge-loop.sh [-c checks] [-t trailer] \"N|subject\" ..." >&2; exit 1; }

log() { echo "$(date +%H:%M:%S) $*"; }
# prints: "<mergeable> <head8> <check1=state,check2=state>"
# shellcheck disable=SC2016 # $want and $w are jq variables
state() {
  CHECKS="$checks" gh pr view "$1" --json mergeable,headRefOid,statusCheckRollup --jq '
    (env.CHECKS | split(",")) as $want
    | "\(.mergeable) \(.headRefOid[0:8]) " +
      ([$want[] as $w | .statusCheckRollup[] | select((.name // .context) == $w)
        | "\($w)=\(.conclusion // .state // "PENDING")"] | join(","))'
}

for spec in "$@"; do
  n=${spec%%|*}; subject=${spec#*|}; asked_at=""
  for _ in $(seq 1 180); do
    s=$(state "$n"); m=${s%% *}; rest=${s#* }; head=${rest%% *}; st=${rest#* }
    case "$m" in
      CONFLICTING)
        if [ "$asked_at" != "$head" ]; then
          log "PR $n conflicting at $head; asking dependabot to rebase"
          gh pr comment "$n" --body "@dependabot rebase" >/dev/null; asked_at=$head
        fi ;;
      MERGEABLE)
        if echo "$st" | grep -qiE 'failure|error|cancelled'; then
          log "PR $n red at $head: $st; stopping"; exit 2
        fi
        want_n=$(echo "$checks" | tr ',' '\n' | wc -l | tr -d ' ')
        got_n=$(echo "$st" | tr ',' '\n' | grep -ciE '=success$')
        if [ "$got_n" -eq "$want_n" ]; then
          log "PR $n green at $head; merging"
          gh pr merge "$n" --squash --subject "$subject" --body "$trailer" && { log "merged $n"; break; }
        fi ;;
    esac
    sleep 20
  done
  [ "$(gh pr view "$n" --json state --jq .state)" = MERGED ] || { log "PR $n not merged; stopping"; exit 3; }
done
log "all merged"
