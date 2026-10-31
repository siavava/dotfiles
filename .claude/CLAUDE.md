# Git identity

Two GitHub accounts share this machine:

- `siavava` <amittaijoel@outlook.com> is the default identity. All ordinary work, every
  commit the user authored or asked for by hand, goes out under it with the usual GPG
  signature.
- `evilalt` <amittaijoel@gmail.com> is the utility identity for automated changes:
  dependency bumps, fixes pushed to Dependabot branches, lockfile or generated-file
  refreshes, and anything a bot or a scheduled job would otherwise have done.

Commit automated changes with `git alt commit …` (the global alias injects the evilalt
name and email for that one command; it changes no state). Those commits are
unsigned by design; do not try to sign them or add a key for that account. Never change `user.name` or
`user.email` to flip between them. When squash-merging a bot's pull request, pass
`--body "Co-authored-by: evilalt <amittaijoel@gmail.com>"` so the utility account is
credited on the merge commit. This rule applies in every repository.

# Code layout

Column width, in every repository: at most 80 columns (preferred), at most 100 when a
line cannot be broken well, at most 130 only when there is truly no other way. A function
definition or call that would run long puts each argument on its own line; long strings
concatenate across lines; long object literals go one field per line. Every `if`, `else`
and `for` uses braces with its body on the next line. Separate the steps of a function
with blank lines rather than cramming them together. No Claude attribution anywhere: no
`Co-Authored-By` trailer on commits and no "Generated with Claude Code" line in PR bodies.

# Background work

Nothing an agent starts may outlive its report. This binds every session and
every subagent it spawns, in every repository.

- Before reporting a task done, list what you started in the background
  (commands, scripts, dev servers, subagents). Wait for the ones your result
  depends on; kill every other one, and anything stuck at a prompt, by its
  process group. A task is not done while one of them is still running.
- Bound every wait. A foreground command gets a timeout, a poll loop gets a
  deadline, and when either passes you kill the process and report that it
  was killed and what it had done, instead of waiting on. Never wait idly on
  something that may never finish.
- Never run a command that can prompt. The shells on this machine alias `rm`,
  `cp` and `mv` to their `-i` forms, and a prompt in a non-interactive shell
  hangs forever: pass `-f`, or call `command rm` and friends. No `read`, no
  editors, no interactive git flags; anything that wants an answer gets it on
  the command line (`yes |`, `--yes`, `-y`).
- An orchestrator checks for its subagents' stragglers before its own report:
  `ps` for processes whose arguments name the session's scratchpad, its
  worktree or the project, kill them, then report.

# Pull requests

Every pull request, in every repository, has this shape:

- The title is the commit style: `(type): a lowercase clause`.
- `## Why`: the problem or the gap in a paragraph or two, naming the design
  document or rule it answers to where one exists.
- `## What`: what the change does, as bullets whose first words are bold,
  with files, routes, settings and constants in backticks, and a line on
  what is deliberately left alone and why.
- `## Verification`: what was run (lint, typecheck, specs with their counts,
  the app on the local stack) and what was looked at, with the measured
  facts rather than adjectives.
- A `<details><summary>Files</summary>` block listing new and changed files.
- A change with any visual or UI effect carries a table of before/after
  snapshots: one row per place and state (surface, scheme, width), a
  screenshot in each cell, hosted where the PR can show it (a path on the
  PR's branch, or an image upload), with the computed values beside it
  where a picture alone would not show the difference. A significant
  redesign, where a full table would run long, carries the most significant
  samples instead, five at most.
- No Claude attribution anywhere in the body.
