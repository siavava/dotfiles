---
description: Commit working-tree changes as granular, conventionally-formatted commits
---

# Commit Code Changes

Commit the current working-tree changes.

> NOTE: related to `/push`

Follow these rules exactly:

## Grouping

- **Fold patches and fixes for the same thing into one commit.** Several edits that
  together address a single concern (one feature, one bug, one figure, one component)
  belong in the same commit, even across multiple files.
- **Separate unrelated changes into separate commits.** Do not lump distinct concerns
  together. Prefer several small, logically-scoped commits over one mixed commit.
- Inspect `git status --short` and `git diff` first, then decide the grouping before
  staging anything. Stage each group explicitly by path (`git add <paths>`) — never
  blanket-stage unrelated work.

## Message format

- Use the established convention: `(type): <short, lowercase description>`.
- Types in use: `feat`, `fix`, `update`, `cleanup` (use the one that fits).
- **The description is an action**: start it with an imperative verb (add, fix,
  migrate, move, drop, rewrite, rename, test, …) saying what the commit does.
  - BAD: `(feat): the timeline as a route, threaded through the page`
  - GOOD: `(feat): migrate timeline to a separate route`
- Keep the subject to one short line, matching the existing `git log` style.
- Add a body only where context is genuinely needed, as one short paragraph (a few
  lines at most). No essays, no bullet lists.

## Hard rules

- **NEVER add Claude as a co-author.** Do not append any `Co-Authored-By` trailer or
  any "Generated with Claude" line to commit messages.
- Do not push unless explicitly asked.
- Do not amend or rewrite existing commits unless explicitly asked.

After committing, show the resulting `git log --oneline` for the new commits.
