---
description: Push the current branch to its remote
---

# Push Code Changes

Push the current branch to its remote with `git push`.

> NOTE: related to `/commit`

Follow these rules exactly:

## Steps

- Run `git status -sb` to confirm the current branch and its relationship to its
  upstream (ahead/behind, or no upstream set).
- If the branch already tracks an upstream, run `git push`.
- If it has no upstream yet, run `git push -u origin <current-branch>` to set it.
- Show the command output so the result — or any rejection — is visible.

## Hard rules

- **Never force-push** (`--force` / `--force-with-lease`) unless the user explicitly
  asks for it.
- Push only the current branch; do not push tags or other branches unless asked.
- If the push is rejected (e.g. a non-fast-forward), stop and report it. Do not pull,
  rebase, merge, or force without the user's say-so.
