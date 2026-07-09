# De-AI frontmatter pass

Second pass of the de-AI rewrite: the first fleet was barred from frontmatter, but the
frontmatter prose IS user-visible UI text (lesson summaries on cards/hovers, subject
briefs on index pages). Rewrite AI-sounding prose there too.

Read the voice rules first: /private/tmp/claude-501/-Users-siavava-workspace-web-study/75f8a788-fe2a-4ec3-b50b-eab7304cef85/scratchpad/deai-style-guide.md
— the "Patterns to hunt and kill" and "Preferred constructions" sections apply verbatim.
This addendum REPLACES that guide's "never edit frontmatter" protection for the specific
fields below; every other hard protection still stands.

## What you may edit

- Lesson files: ONLY the prose text inside the `summary:` block scalar (usually
  `summary: >` or `summary: |`). Nothing else in the frontmatter, nothing in the body
  (the body was already handled).
- Subject `index.md` files: ONLY the prose inside `blurb:`, `description:`, and the
  `brief:` list's `p:` and `caption:` text values.

## What you must NOT touch

- Keys, key order, list structure, indentation style, the scalar indicator (`>` / `|`),
  `title`, `module`, `order`, `topics`, `sources`, `status`, `draft`, `fig`/`n`/`large`
  entries — structure stays byte-identical except the prose you rewrite.
- Math `$…$` inside summaries: keep as-is.
- Inline HTML tags in index briefs (`<strong>`, `<em>`): you may keep or drop the tag,
  but do not introduce new markup.

## YAML safety rules

- Rewritten lines must keep the block scalar's exact indentation (usually 2 spaces
  deeper than the key).
- Inside a block scalar (`>` or `|`), colons, quotes, and dashes are safe — but do NOT
  start a line with `- ` (looks like a list item) and do not add/remove the trailing
  newline structure. In `>` folded scalars a blank line = paragraph break; don't add
  blank lines.
- For single-line quoted values (`caption: "…"` style), keep the quoting style.
- Keep summaries roughly the same length or shorter — they are card text, not essays.

## Voice targets seen in this corpus's summaries

"X is a trap", "honest reporting", "real or luck", "the cure is structure",
"the trick", "in disguise", "cashes that in", "changed everything", "the through-line",
"embarrassingly simple", "Depth is the trick", "Learning is just calculus run backwards",
"Scale turned the recipe into a revolution", anthropomorphized models/metrics,
"not X but Y" reveals, teaser/cliffhanger sentences. Rewrite to plain statements of
what the lesson covers. Terse and factual beats punchy.

## Method

For each assigned file: Read only the frontmatter (first ~45 lines is enough; extend if
the summary runs longer). If the summary/brief prose is already plain, move on — many
are fine. Edit surgically. Report files touched vs already clean.
