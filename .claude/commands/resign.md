---
description: Re-sign unsigned commits on the current branch (e.g. after a history rewrite)
---

# Resign Commits

Re-sign commits on the current branch that ended up **unsigned** — most often because a
history rewrite (`git rebase`, `git filter-branch`, `git commit-tree`) dropped their
GPG/SSH signatures. Restores the branch to fully-signed.

> NOTE: related to `/commit`, `/describe-commits`.

## When to use

- After `/describe-commits` or any `filter-branch`/rebase that stripped signatures.
- When `git log --format='%h %G? %s'` shows `N` (unsigned) on commits that should be `G`.

## Steps

1. Confirm signing is configured: `git config --get commit.gpgsign` (and
   `user.signingkey` / `gpg.format`). If it is not, stop and tell the user — there's
   nothing to sign with.
2. Show the current signature state of the range: `git log --format='%h %G? %s' <base>..HEAD`.
   Pick `<base>` = the merge-base with upstream (`@{upstream}`), or a base the user names.
   Do not re-sign commits outside the branch's own work.
3. Re-sign by replaying the range with signing on:
   `GIT_SEQUENCE_EDITOR=true git rebase -f --gpg-sign <base>`
   (the `-f` forces re-creation even when the branch is already linear/up-to-date).
4. Verify every commit in range now shows `G`: `git log --format='%G?' <base>..HEAD | sort | uniq -c`.

## Hard rules

- This **rewrites history** (new hashes). If the range was already pushed, the re-signed
  commits will need a force-push — use `--force-with-lease`, and only when the user has
  explicitly asked to push. Do NOT push on your own.
- Signing may prompt for a passphrase; if the agent isn't cached the rebase can stall or
  fail with no tty — surface that plainly rather than hanging silently.
- Submodules sign independently; a rewrite of the superproject does not unsign a
  submodule's own commits.

## Report

Show the before/after `%G?` counts and confirm the whole range is `G`. If a push is
needed, say so and wait for an explicit `/push`.
