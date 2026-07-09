---
name: author-course-notes
description: Given reference book(s) (PDF or text) and a subject, author a complete, publication-quality set of course notes — dense technical lessons with abundant TikZ illustrations, algorithm blocks, and worked math — then run the full consistency pipeline; coverage audit against the reference, gap filling, visual figure-overlap sweep, over-dense lesson splitting, prose voice cleanup, frontmatter polish, and build verification. Use when asked to write, extend, or overhaul a subject's notes in a course-notes site, or to run any subset of the follow-up passes on existing notes.
---

# Author Course Notes

Write a comprehensive subject (30–70 lessons, 80k–300k words, 100+ figures) from
reference books, at the quality bar of a well-edited textbook, and leave it verified
and consistent with the rest of the site. The method below was proven across six
subjects (algorithms, computer architecture, deep learning, RL, AI, NLP); follow it
in order — every phase exists because skipping it produced visible defects.

## Inputs

Ask for anything missing before starting:

1. **Reference book(s)** — PDFs or text. These are the ONLY citable sources. Record
   the allowed set per subject and never cite anything else — in particular, never
   cite lectures, professors, or courses, and avoid indirect tells like "in lecture"
   or "the professor". If the user names books, that list is a hard whitelist.
2. **Subject + scope** — new subject from scratch, extend an existing one, or run
   only specific follow-up passes.
3. **Target repo** — a content-pipeline site (see Project integration). For other
   repos, adapt the file conventions but keep the method and standards.

## The method — phases in order

### Phase 1: Coverage plan

Read the reference's table of contents and skim each chapter. Produce a
module/lesson outline mapping every reference chapter/section to a lesson (or a
deliberate omission with a reason). Get user sign-off on the outline if scope is
ambiguous. Number modules and lessons; each lesson gets the source sections it will
cite.

### Phase 2: Author lessons (parallel)

Fan out background agents, one per module (or ~5–8 lessons per agent). Each agent
writes complete lessons per the Standards section below. Lessons are marked draft
until the subject ships. Density target: technical-paper, not blog — a 3–5k word
lesson typically carries 5–10 display-math blocks, 2–5 figures, 1–3 tables, and an
algorithm block where a procedure is central.

### Phase 3: Coverage audit + gap fill

A fresh set of agents compares the written subject against the reference book
chapter by chapter and reports gaps (missing topics, skipped proofs, absent
examples). Then fill: new lessons for missing chapters, expansions for thin
sections. Micro-accuracy matters too — verify factual claims with numbers in them
(a claim like "$2^{100}$ exceeds the number of atoms in the universe" is off by 50
orders of magnitude; agents write these when reaching for drama).

### Phase 4: Enrichment — math over prose

Audit every lesson for "english essay" sections: dense prose with little math,
few figures, no structure. Rewrite with preference for (in order): terse scientific
language; mathematical notation and formulas; figures; algorithms and sample code;
tables for comparisons. Prose that enumerates 2+ named things becomes a bulleted
definition list with bold terms.

### Phase 5: Illustration pass

Add figures generously wherever a picture carries the idea better than a paragraph:
data-structure states, algorithm traces, architecture diagrams, plots of
trade-offs, geometric arguments. Refined scale, not cartoonish. Every figure gets a
caption that adds information (not "diagram of X").

### Phase 6: Visual figure audit

Automated overlap checkers miss most real defects (label-on-arrow, label-on-curve,
crowded text, arrow-through-node). Render every figure to PNG and have vision
agents inspect each one, reporting text overlapping other elements, arrows
overlapping nodes or shown behind arrowheads, and criss-crossing labels. Fix by
repositioning (xshift/yshift, anchor changes, moving labels off curves), not by
shrinking text. Re-render and re-inspect after fixes. Calibrate the renderer first:
some render paths introduce phantom intra-word letter gaps that do not ship — check
a known-good figure before flagging spacing artifacts.

### Phase 7: Simplify and split

Lessons that grew past ~6–8k words or that cover two ideas get split into a
NN-part-2 lesson (renumber siblings; update links). Over-dense paragraphs get
broken into structure. Do not delete coverage — redistribute it.

### Phase 8: Voice pass

Read `voice-guide.md` in this skill directory — it is the exact guide handed to the
rewrite fleet, with BAD → GOOD calibration examples from the user. Fan out agents
(~50k words / 10–15 files per agent, disjoint shards) to aggressively rewrite
machine-sounding prose: anthropomorphized concepts ("the metric asks…", "the loss
punishes…"), metaphor-as-structure ("the cure is", "the engine behind", "the
workhorse"), portentous openers ("At its core", "Crucially,"), "not X but Y"
reveals, rhetorical-question chains, economy metaphors around math ("buys",
"pays", "survives"), em-dash overuse (~6/1k words max). Then a second, lighter
fleet does the frontmatter prose (lesson `summary:` blocks, subject `brief:`/
`blurb:` entries) under the YAML safety rules in `voice-guide-frontmatter.md` —
frontmatter is user-visible UI text and the body fleet must be barred from it
(YAML breakage risk), so it is always a separate pass.

### Phase 9: Verification gate

Run the full static build. Required clean state:

- Build exits 0; route count matches expectation (record it; a drop means a lesson
  was truncated or a link broke).
- Zero KaTeX errors in the built HTML: `grep -rl "katex-error" <output-dir>` must
  return nothing. Every hit is a real red error box a reader would see.
- All figures render (the build reports rendered/live figure counts).
- Diff integrity scan: zero changed lines matching tikz internals
  (`tikzpicture|\\draw|\\node|% *caption`), zero changed code-fence lines, zero
  changed headings, zero introduced single-`*` emphasis
  (`grep -E '(^|[ (])\*[A-Za-z][^*]{0,60}\*([ .,;:)]|$)'` on added lines,
  excluding lines with `$` or backticks).

### Phase 10: Commit

Granular signed commits, `(type): lowercase description` convention (types: feat,
fix, update, cleanup — parentheses required). Group by subject/module keeping each
commit under ~1k changed lines. Descriptive language ("clarify language in…",
"add worked examples to…"); never reference the model or automation in messages.
Never add a co-author trailer. Never commit or push without an explicit ask.

## Standards (content)

- **Callouts**: definitions/theorems/lemmas/invariants use
  `> **Definition (Name).** …` — a bare `> …` renders as a quotation box and is
  wrong for elements. Prose inside the callout follows all voice rules.
- **Algorithm blocks**: ```algorithm fences with keyword-structured pseudocode
  (`for each … do`, `repeat … until`), never narrated steps ("Loop for each…").
  `\quad`/`\;` outside `$…$` leaks literally — keep spacing commands inside math.
- **Emphasis**: bold `**text**`, italic `_text_`, NEVER single `*` (don't touch
  `*` inside math or code).
- **Internal links**: clean absolute routes with no numeric prefixes
  (`/subject/module/lesson`), or the build's link crawl 404s.
- **Math**: `\ast` for superscript stars (`a^\ast`, guard a following letter:
  `\ast{}b`); `\textsc{A*}` keeps a raw `*` (text mode). Literal dollar signs in
  math use `\text{\textdollar}` — bare `\textdollar` is text-mode-only in KaTeX,
  and an escaped `\$` inside `$…$` breaks the markdown math splitter. Display
  blocks inside blockquotes need `$$` delimiters on their own `> `-prefixed lines.
  Define shared operators once in the site's macro map (single source of truth),
  never inline `\operatorname{…}` repeatedly.
- **Frontmatter** per lesson: title, module, moduleNumber, lessonNumber,
  order (= moduleNumber×100 + lessonNumber), `summary: >` (card text — plain,
  factual, same voice rules), topics, sources (book + section refs from the
  whitelist only), `draft: true` until released.
- **Footnotes** cite the reference with section numbers.

## Standards (figures)

TikZ blocks are display-math blocks: `$$` + `% caption: …` comment lines +
`\begin{tikzpicture}` immediately after + code + `$$`. Rules learned the hard way:

- `\definecolor` goes INSIDE the tikzpicture. Use one accent color plus neutrals;
  colors auto-map to theme variables classified by lightness — so: `gray!N` with
  low N becomes invisible; use `black!45–55` for muted lines/text; fills are a
  light tint (`acc!8`–`acc!14`) with a solid outline, never solid accent fills.
- Node text is real TeX with a minimal font set: **no Greek letters** (they garble
  — keep Greek in captions/prose where KaTeX renders it), **no bare `|`** (crashes
  the renderer — use `$|$`), no `° µ ± —` or `\text…` companions (missing-font
  crash class), break fi/fl ligatures as `f\/i`. Math arrows in node text garble —
  draw arrows or use `=`, `-`, `:`.
- 3-D: `\tdplotsetmaincoords{θ}{φ}` sits between the caption comment and
  `\begin{tikzpicture}`; draw far cells first (anti-diagonal) so nearer bars
  occlude correctly.
- Layout: arrows never overlap nodes and never disappear behind arrowheads;
  labels never sit on curves or cross each other; when a region is crowded, move
  the label out and, only if needed, leader-line it.
- The figure cache is keyed on the exact block text (caption included) — any edit
  re-renders that figure; never edit figure blocks during a prose-only pass.

## Parallelization

- Shard by word count (~50k words / 10–15 files per agent), files sorted by path
  so shards stay module-contiguous and disjoint. 20–30 background agents is
  routine for a full-corpus pass.
- Every fleet gets ONE shared written guide (style rules + hard protections +
  method), written to a scratchpad file the agents Read — never inline divergent
  instructions per agent.
- Agents report per-file edit counts and what they judged already clean.
- **On agent failure** (usage limit, API error): resume the SAME agent by sending
  it a message — its context knows exactly which files it finished. Tell it not to
  re-process completed files and to re-check the in-flight file against disk
  before re-applying edits. Trust the agent's own transcript over your notes about
  its progress. Never re-launch a fresh agent on a partially-processed shard.
- Dev servers crash on bulk external file edits — don't run one during a fleet
  pass; verification is the static build.

## Hard protections (every pass, every fleet)

- Never edit inside `$$…tikzpicture…$$` blocks (including `% caption` lines)
  during non-figure passes; never edit math content, code fences, frontmatter
  (except the dedicated frontmatter pass), MDC component markers, or link targets.
- Never change section headings during prose passes (anchors may be linked).
- Citation whitelist is absolute (see Inputs).
- Prose passes change VOICE only — no technical claims, numbers, or notation;
  restructuring a paragraph into a definition list is allowed, deleting coverage
  is not. Flag suspected factual errors for a separate fix; don't silently
  "improve" facts mid-pass.

## Bulk-edit hazards (learned from repairs)

Regex-driven bulk conversions over many files WILL hit edge cases; prefer agents
making contextual edits. If a mechanical sweep is unavoidable: (a) inline `$…$`
math can span line breaks, so naive `$`-pairing desyncs and can eat `**bold**`;
(b) converted tokens can merge with following letters into undefined commands —
guard with `{}`; (c) text-mode contexts (`\textsc{…}`) reject math-mode commands;
(d) mask code fences and math with private-use sentinel characters (U+E000-range),
never with ASCII sentinels that can collide with prose. After any sweep, run the
verification gate before moving on.

## Project integration (course-notes site)

For the Nuxt content site this skill was built on (`~/workspace/web/study`):
content lives in `content/NN.subject/NN.module/NN.lesson.md`; subject `index.md`
holds `blurb`/`description`/`brief` (frontmatter-only, user-visible); build is
`bun run generate` (never while a dev server runs); built HTML in `.output/public`;
figure tooling: `figrender` (PNG render; has phantom letter-gap artifact),
`figcheck` (text-vs-text overlaps only — blind to label-on-arrow/box/curve),
`transformers/tikz/figlabels.ts` (curve-overlap class); figure cache `.cache/tikz`
swept by `scripts/sweep-tikz.ts` and persisted to Netlify Blobs by
`scripts/cache-blobs.ts save` (runs post-generate; a warm store is what keeps
platform builds fast — confirm `+0/0 uploaded` or that new figures uploaded).
KaTeX macros: `configs/latex/` (operators in `operators.ts`, shared with tikz via
`transformers/tikz/preamble.ts`). In other repos, map each concept (content dir,
build command, output dir, figure pipeline) before starting; the method and
standards transfer unchanged.
