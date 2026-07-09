---
description: Split a large or mixed working tree into granular, size-capped semantic commits
---

# Recommit (granular, size-capped)

The heavy-duty companion to `/commit`, for when the working tree is a **large or mixed
pile** of changes (a big feature branch, a bulk edit, a long-running uncommitted session).
Break it into many small, semantically-scoped commits, none of them huge.

> NOTE: related to `/commit` and `/push`. For a handful of tidy changes, use `/commit`.

## Grouping (semantic first, then size)

1. **By concern.** Separate distinct concerns into distinct commits: feature vs. bugfix
   vs. cleanup/refactor vs. config vs. docs vs. dependency bumps. Inspect `git status
   --short` and `git diff` first, and read ambiguous diffs to attribute them correctly
   (a file may carry two concerns — commit it under the dominant one, or split by hunks
   with `git add -p` if cleanly separable).
2. **By module/directory.** Within a concern, group by feature area or top-level module
   so each commit is a coherent unit.
3. **Size cap.** Aim for **no commit over ~1000 changed lines**. Split an oversized group
   into batches by file. A single file whose own diff exceeds the cap (or an atomic unit,
   see below) is allowed to exceed it — call those out in the report rather than splitting
   one file's diff across commits.

## Atomicity (do not split these across commits)

- A rename/move: the deletion of the old path **and** the addition of the new path.
- A renumber/reshuffle chain that would leave an inconsistent intermediate state.
- A source file and the test that must move or change with it.
- Generated output and the source that produced it.

## Mechanics (robust)

- Build the changed-file list without `git status --porcelain` string-parsing (it
  collapses untracked dirs and is IFS-fragile). Use:
  `git diff --name-only HEAD -- <dir>` (tracked mods + deletions) unioned with
  `git ls-files --others --exclude-standard -- <dir>` (untracked), `sort -u`.
- Iterate with `while IFS= read -r f` + process substitution (`done < <(...)`) so counters
  persist and filenames with odd whitespace/IFS don't break the loop.
- Stage explicitly per file (`git add -A -- "$f"`); never blanket-stage unrelated work.
  Commit a batch when its staged size approaches the cap.
- Message format: match the repo's existing convention (inspect `git log`). Common style:
  `(type): <short, lowercase description>` with `feat`/`fix`/`update`/`cleanup`/`docs`.
  Make each message name what that specific commit changed, not a generic label.

## Hard rules

- **NEVER add Claude as a co-author** or any "Generated with" trailer.
- Do NOT push. Do NOT amend or rewrite already-pushed commits unless explicitly asked.
- Do NOT commit submodule pointer bumps, generated caches, or secrets unless asked.
- If commit signing is configured (`commit.gpgsign=true`), commits sign automatically —
  don't disable it.

## Report

Show `git log --oneline` for the new commits, the largest few by line count, and flag any
that unavoidably exceed the cap (single big file / atomic unit). Then stop.
