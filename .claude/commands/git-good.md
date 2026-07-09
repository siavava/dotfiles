---
description: Review the session's work and distill it into a reusable global skill that can replicate it anywhere
---

# Git Good — turn this session's work into a skill

Two phases: (1) thoroughly review everything done in the session (or the scope the
user passes as arguments), then (2) author a **global skill** that lets any fresh
session replicate that work, one-shot, at the same level of quality.

> NOTE: related to `/handoff` (which captures session *state* for resuming; /git-good
> captures the session's *method* for repeating).

## Phase 1 — Review the work

Reconstruct what was actually done, end to end, before writing anything:

- Walk the session history: the user's asks, the approach taken, every significant
  correction the user made (corrections are the highest-value content — they encode
  the difference between the first attempt and the accepted result).
- Inspect the artifacts: `git log` / `git diff` for the session's commits, files
  created or edited, scratchpad guides written for subagents, verification commands
  run and their outputs.
- Identify the *repeatable method* hiding in the specifics: phases, ordering
  constraints, fan-out/parallelization strategy, quality gates, failure modes hit
  and their fixes.
- List the tacit rules that were never written down but were enforced (style
  conventions, things deliberately NOT touched, protections against breaking
  adjacent systems).

If the user passed arguments, review only that scope. If the session mixed several
unrelated efforts and the user didn't scope, ask which one to distill.

## Phase 2 — Author the skill

Create `~/.claude/skills/<name>/SKILL.md` (a directory per skill). Pick a name that
says what the skill DOES (verb-first, kebab-case, e.g. `author-course-notes`,
`migrate-api-versions`) — never name it after this session or the project unless the
skill is inherently project-bound.

Frontmatter:

```markdown
---
name: <kebab-case-name>
description: <one paragraph: what it does, what inputs it needs, when to trigger it>
---
```

The body must be complete enough that a session with ZERO context — no memory of
this session, this repo, or this user — produces work of the same quality. Test
every line against that bar. Include, at minimum:

1. **Inputs** — what the skill needs to be given (files, references, scope choices)
   and what to ask the user when something is missing.
2. **The method** — the full phase-by-phase procedure with ordering constraints and
   *why* each phase exists. Include the parallelization strategy where the session
   used one (how work was sharded, what each agent was told, how results merged).
3. **The standards** — every style/quality rule enforced this session, stated as a
   rule with a BAD → GOOD example wherever the session produced one. Corrections
   the user made during the session MUST appear here.
4. **Hard protections** — what must never be touched or broken, and the failure
   modes seen this session with their fixes.
5. **Verification** — the exact gates that prove the work is done (commands, what
   clean output looks like, what to do on failure).
6. **Scaling notes** — how the method changes with size (one file vs. a whole
   corpus), when to fan out subagents vs. work inline.

Reference project-specific paths/tools only inside a clearly-marked "project
integration" section, with generic fallbacks described for other contexts.

## Rules

- Skill files are instructions to a future model, not documentation for humans:
  imperative voice, concrete thresholds, no motivational filler.
- Do not inline entire reference documents the future session can read itself —
  point to them; inline only what is load-bearing.
- If a scratchpad guide from this session already encodes part of the method
  verbatim (e.g. a style guide handed to subagents), copy it into the skill
  directory as a supporting file and reference it from SKILL.md.
- After writing, print the skill path and a one-paragraph summary, and remind the
  user it can be invoked in any future session by name.
