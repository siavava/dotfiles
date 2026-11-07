#!/usr/bin/env bash
# Say whether a sub-session is parked: its transcript's last tool call has no
# result. Prints one line: "ok <age>s" (last call answered), "PENDING <tool>
# <age>s" (a call waiting that long), or "no transcript".
#
# usage: stall.sh <session worktree path>
set -uo pipefail

wt="${1:?session worktree path}"
esc=$(printf '%s' "$wt" | sed 's#[/.]#-#g')
dir="$HOME/.claude/projects/$esc"
f=$(ls -t "$dir"/*.jsonl 2>/dev/null | head -1)

if [ -z "$f" ]; then
  echo "no transcript"
  exit 0
fi

python3 -I - "$f" <<'EOF'
import json, sys, time
from datetime import datetime, timezone

calls = {}
last_ts = None
for line in open(sys.argv[1]):
    try:
        o = json.loads(line)
    except Exception:
        continue
    if o.get("type") not in ("assistant", "user"):
        continue
    ts = o.get("timestamp")
    if ts:
        last_ts = ts
    msg = o.get("message", {})
    for c in msg.get("content", []) if isinstance(msg.get("content"), list) else []:
        if not isinstance(c, dict):
            continue
        if c.get("type") == "tool_use":
            calls[c.get("id")] = (c.get("name"), ts)
        elif c.get("type") == "tool_result":
            calls.pop(c.get("tool_use_id"), None)

def age(ts):
    if not ts:
        return 0
    t = datetime.fromisoformat(ts.replace("Z", "+00:00"))
    return int((datetime.now(timezone.utc) - t).total_seconds())

if calls:
    name, ts = list(calls.values())[-1]
    print(f"PENDING {name} {age(ts)}s")
else:
    print(f"ok {age(last_ts)}s")
EOF
