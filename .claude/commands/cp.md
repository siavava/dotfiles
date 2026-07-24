---
description: Commit working-tree changes, then push (shorthand for /commit & /push)
---

# Commit & Push

Shorthand for running `/commit` immediately followed by `/push`.

Do both, in order:

1. **Commit** — follow every rule in `/commit`: inspect `git status --short` and
   `git diff` first, group changes by concern into granular commits staged
   explicitly by path, use the `(type): lowercase description` convention, never add
   a `Co-Authored-By`/"Generated with Claude" trailer, and never amend existing
   commits. Show the resulting `git log --oneline` for the new commits.

2. **Push** — then follow every rule in `/push`: confirm the branch and upstream with
   `git status -sb`, `git push` (or `git push -u origin <branch>` if no upstream),
   show the output, and never force-push. If the push is rejected, stop and report —
   do not pull, rebase, merge, or force.

If there is nothing to commit, say so and skip the push.
