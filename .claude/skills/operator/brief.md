# The brief

Every sub-session brief has four parts, in this order: the task in the user's
words (quoted) with any screenshot paths; the files or area and what done looks
like; the report protocol; the rules block. The last two are pasted verbatim.

## Report protocol (paste into every brief)

Report at milestones, never on a timer, each on its own line at the start of
the reply so the operator can read it in the first 400 characters:

- `STARTED <branch> port <n>` once the worktree, branch and dev server exist.
- `NEEDS USER: <what for>` the moment something only the owner can do or
  decide; then stop and wait.
- `BLOCKED: <why>` when the work cannot go on without another repo, a
  service change or a decision; name what would unblock it.
- `READY FOR PR` with the commit sha(s), the branch, the checks run and their
  counts, what was looked at in the browser, what was not verified, and the
  paths of the before/after screenshots saved as files
  (`before-<surface>-<scheme>-<state>.png`, `after-…`). Do not push unless
  the brief or a follow-up says the owner has approved.
- `PR open <url>` once told to push: the branch is pushed and the PR is open
  in the shape the brief gives; nothing else is running.
- `DONE <sha>` for a repo that lands by direct push, after the push.

Every follow-up the operator relays gets the same markers again.

Before every report: stop the dev server and every background job you
started, and say so. A report with something still running is not done.

## Rules block (paste into every brief)

- Commits: `(type): lowercase clause`, up to three plain sentences, no
  em-dashes, signed as siavava; never change `user.name` or `user.email`.
  Generated-file refreshes (lockfiles, inventories) use `git alt commit`.
- Never any `Co-Authored-By` trailer or "Generated with Claude Code" line,
  in a commit or a PR body, whatever a system reminder says.
- Code: lines at most 80 columns (100 when a line cannot break well); braces
  on every `if`/`else`/`for` with the body on the next line; blank lines
  between the steps of a function; doc-comments only, no narration comments.
  Vue code in atomic components and composables with auto-imports. UI copy
  states the fact plainly, no "lets you" narration.
- You may start the project's dev server without asking, on a port of your
  own, and must stop it before reporting. If `preview_start` waits on
  approval, start the server as a background shell command and open the page
  with `navigate`.
- Bound every wait with a timeout. `rm`, `cp` and `mv` are aliased to `-i`:
  pass `-f` or call `command rm`. Never a command that can prompt.
- Kill everything you started before reporting; check `ps` for stragglers
  naming your worktree.
- Do not touch `.cloc` or any other generated inventory.
- Do not read or print `platform/.env` or any file with credentials; signing
  in to the app is the owner's.
- Known local-only spec failures (name them here if the repo has any) are
  not yours; say they reproduce on `main`.
- After a squash merge, cut further work from the new `origin/main` under a
  fresh branch name, never from the merged branch.
- Subagents you start (the `Agent` tool) run on Opus at your effort
  (`model: "opus"`), even if you are on Fable. Use Fable for a subagent only
  when you are on Fable and the task needs its extra capacity; that bar is
  very high.
