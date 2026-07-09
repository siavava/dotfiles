---
description: Write a session-handoff document so any fresh session can resume this work
---

# Session Handoff

Summarize the current session's work into a durable handoff document that a brand-new
session (with none of this context) can read and resume from.

> NOTE: related to `/git-good` (which distills the session's *method* into a reusable
> skill; /handoff captures the session's *state*).

## Where it goes

Write the document to `.claude/handoffs/<YYYY-MM-DD>-<short-slug>.md` in the current
project (create the directory if needed). If a handoff for the same stream of work
already exists there from today, update it in place instead of creating a sibling.
After writing, print the file path and a 5-line digest to the user.

## What it must contain

Structure the document with these sections, in this order. Write for a reader with
zero context — no session shorthand, no "as discussed above", every codename expanded
on first use.

1. **Goal** — what the user is ultimately trying to achieve, in 2-3 sentences.
2. **State of play** — what is DONE (with evidence: commits pushed, tests passing,
   builds green), what is IN FLIGHT (partially complete, with exactly what remains),
   and what is NOT STARTED but already agreed on.
3. **Key decisions** — choices made during the session and *why* (the reasoning is
   what a resuming session needs; the choice alone is not enough). Include decisions
   that were reversed and why.
4. **How to verify** — the exact commands/checks that prove the current state works
   (build commands, test suites, error-scan greps), and their last-known-good output.
5. **Gotchas** — anything that bit us this session: flaky tooling, sharp edges,
   things that look wrong but are intentional, things that look fine but are broken.
6. **Next steps** — an ordered, actionable list. Each step self-contained: file
   paths, function names, the acceptance criterion.
7. **Pointers** — key files touched (as a short annotated list, not a dump),
   relevant scratchpad/artifact paths, related handoffs or skills.

## Rules

- Facts only from this session's actual history — never invent or embellish state.
  If something is uncertain (e.g. a background task that may not have finished),
  say so explicitly.
- Keep it under ~150 lines. A handoff nobody reads is worse than none. Densest
  useful summary wins; drop process narration ("first I tried...") unless the
  failed attempt is itself a gotcha.
- If the session covered several unrelated streams of work, write one handoff per
  stream, each with its own slug.
- If arguments are passed (`/handoff <scope>`), restrict the handoff to that scope.
