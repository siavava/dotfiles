---
description: Remove narration/noise comments repo-wide, keeping doc-comments and directives
---

# Tidy Comments

Strip comments that only **narrate** what the code does or restate the obvious, while
keeping the comments that carry real information. Language-agnostic. This edits source
only — it does not commit or push.

> NOTE: related to `/commit`. Run this before committing, then review the diff.

## Scope

- Default: the files changed in the current diff (`git diff --name-only HEAD` plus
  untracked source files). If the user names a path/dir/glob, use that instead. If they
  say "whole repo", sweep all source, but **never** touch vendored/generated trees
  (`node_modules`, `dist`, `build`, `.next`, `target`, `vendor`, `third_party`, lockfiles,
  minified files, snapshots).
- Fan out with subagents by directory when the surface is large; each agent does the
  work itself, verifies, and reports counts.

## DELETE (the point of the command)

- Inline comments inside function/method bodies that narrate the next line(s) or the
  author's reasoning: `// now we loop`, `// build the map`, `# increment counter`,
  `// we do X because Y` where the code already shows X.
- Step/section-divider comments (`// --- Setup ---`, `# === helpers ===`).
- Redundant comments restating a name or type (`// the user store`, `// returns bool`).
- Commented-out code (dead code) — remove it; git history is the archive.
- Template/markup narration comments (pug `//-`, HTML `<!-- ... -->` used as notes),
  and stylesheet narration (`// this centers it`).

When deleting, remove the whole comment and any blank line it leaves behind; keep the
surrounding code byte-identical otherwise. Bias **hard** toward deletion — when unsure
whether a comment adds information beyond the code, delete it.

## KEEP (do not touch)

- **Doc-comments on exported/public API**: JSDoc `/** … */` on exports, Python module/
  class/function docstrings, Rust `///` and `//!`, Go doc comments, Java/C# `/** … */`.
  These are the sanctioned docs.
- Tooling/directive comments: `eslint-disable*`, `@ts-expect-error`, `@ts-ignore`,
  `prettier-ignore`, `// nolint`, `# type: ignore`, `# noqa`, `# pragma`, `#[allow(...)]`,
  `// @vite-ignore`, shebangs, coding/encoding lines, license/copyright headers.
- Actionable `TODO`/`FIXME`/`HACK`/`XXX` with a concrete note.
- A **rare** one-line caveat about a genuinely non-obvious footgun whose loss risks a
  real regression (a browser/OS quirk, an ordering requirement, a security rationale not
  visible from the code). Keep it terse. If in doubt, delete.

## Verify (only what you changed)

- Run the project's linter/formatter and (fast) typecheck on the changed files if one
  exists (eslint, ruff, gofmt, cargo check, etc.). Deleting comments must not change
  behavior or break lint.
- Re-scan changed files: no narration lines should remain — only doc-comments and the
  directives listed above.

## Report

Per area: files touched, comments deleted, doc-comments/directives preserved, and any
caveat you deliberately kept (with the one-line reason). Then stop — do not commit.
