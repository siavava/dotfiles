---
description: Tidy comments, commit working-tree changes, then push (shorthand for /tidy-comments & /commit & /push)
---

# Tidy, Commit & Push

Shorthand for running `/tidy-comments`, then `/commit`, then `/push`.

Do all three, in order:

1. **Tidy** — run `/tidy-comments` on its default scope (the files in the current diff
   plus untracked source files) and follow every rule in it: delete narration and
   dead code, keep doc-comments and directives, verify with the project's linter.
   Fold the resulting edits into the commits below; never give them a commit of
   their own or mention the tidy in a commit message.

2. **Commit** — follow every rule in `/commit`: inspect `git status --short` and
   `git diff` first, group changes by concern into granular commits staged
   explicitly by path, use the `(type): lowercase description` convention, never add
   a `Co-Authored-By`/"Generated with Claude" trailer, and never amend existing
   commits. Show the resulting `git log --oneline` for the new commits.

3. **Push** — then follow every rule in `/push`: confirm the branch and upstream with
   `git status -sb`, `git push` (or `git push -u origin <branch>` if no upstream),
   show the output, and never force-push. If the push is rejected, stop and report —
   do not pull, rebase, merge, or force.

If there is nothing to commit, say so and skip the push.
