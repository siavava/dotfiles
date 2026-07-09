---
description: Rewrite terse/generic commit messages on the branch to describe the actual changes
---

# Describe Commits

Rewrite vague or generic commit messages (`update`, `wip`, `fix stuff`, `enrich module`)
on the current branch so each names what it actually changed — derived from the commit's
files. Leaves already-good messages untouched.

> NOTE: rewrites history. related to `/commit` and `/resign`.

## Range

- Default to **unpushed** commits only: `@{upstream}..HEAD` (or `main..HEAD` / a base the
  user names). Rewriting pushed commits requires a force-push — do not touch them unless
  the user explicitly accepts that.
- Confirm the range and count before rewriting.

## How

- Use `git filter-branch --msg-filter` (or an equivalent rebase reword) keyed on each
  commit's changed files via `git show --name-status --pretty=format: "$GIT_COMMIT"`.
- Only rewrite messages that match the "generic" set the user points at (or obvious
  placeholders); pass every other message through **unchanged**.
- Derive the description from the changed paths: prefer Added/Modified files; fall back to
  Renamed (destination) or Deleted paths for move/renumber commits. Turn file stems into a
  short readable phrase; keep the repo's `(type):` prefix if it has one.
- Make it **idempotent**: strip any existing generated suffix before appending, so
  re-running doesn't double up.

## CRITICAL — signatures

`git filter-branch` and history rewrites **strip GPG/SSH signatures and do not re-apply
them**. If `commit.gpgsign=true` (or the branch's commits were signed), the rewrite leaves
them unsigned. After rewriting, **re-sign the range** (`git rebase -f --gpg-sign <base>`,
i.e. run `/resign`) and verify `git log --format='%G?'` shows all `G`.

## Hard rules

- Do NOT push. If the range was already pushed, stop and tell the user a force-push
  (`--force-with-lease`) is required, and wait for explicit approval.
- Do NOT change commit content, author, or dates — only messages (and re-signing).
- Keep the `refs/original/` backup filter-branch creates until the user is satisfied.

## Report

Show a sample of before→after messages, confirm 0 generic messages remain in range, and
confirm signatures are intact (all `G`) if signing is on. Then stop.
