# Pull request shape

Title: `(type): a lowercase clause`, the same clause as the branch's one commit
or the batch's theme. Body: flowing paragraphs and one-line bullets, never
hard-wrapped. No attribution anywhere.

```markdown
## Why

One or two paragraphs: the problem or the gap, naming the design document,
rule or owner's ask it answers to.

## What

- **Bold first words.** What the change does, with files, routes, settings and
  constants in backticks. One bullet per idea.
- **Left alone:** what was deliberately not changed and why (the inventory,
  which follows separately; a phone layout that was already so; …).

## Verification

- Lint and typecheck: `exit 0` / clean.
- Specs with counts: "the 10 files touching the bar: 212 passed; whole suite
  1,302 files pass, 2 fail (<names>, the known local-only failures)".
- What was looked at: surfaces, schemes, widths, measured values.
- Not verified: the honest list.

## Before and after

For any visual change. Hosted screenshots when the repo has a way to show
them; otherwise "No hosted screenshots; the values below are as measured."
and a table with one row per place and state.

| Place | Before | After |
|---|---|---|
| Find row, desktop | 56px rounded field at 16px, toggles as text | 24px square field at 12px, toggles as 20px squares inside the field |

<details><summary>Files</summary>

New:

- `path/one.vue`

Changed:

- `path/two.ts`

Deleted:

- `path/three.ts`

</details>
```

`scripts/files-block.sh` prints the Files block from
`git diff --name-status origin/main...HEAD`.

Inventory-only PR (a `.cloc` refresh after a batch): the same shape in six
lines; Verification says the repo's CI should find the code unchanged and
skip the code legs, as it did on earlier such PRs.
