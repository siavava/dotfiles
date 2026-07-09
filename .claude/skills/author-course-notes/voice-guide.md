# De-AI rewrite guide

You are rewriting course-notes prose to remove AI-sounding writing. Be **aggressive**: rewrite any sentence that sounds like an LLM wrote it. The goal is terse, human, scientific prose — the voice of good lecture notes, not a magazine explainer.

## The user's own examples (calibrate to these)

BAD:  "A worked example makes the imbalance trap concrete. Take a disease..."
GOOD: "For example, take a disease..."

BAD:  "The cure is to score the two error types separately."
GOOD: "To address this, score the two error types separately."

BAD (flowing anthropomorphized prose):
"From these counts come the three metrics that survive imbalance. Precision asks "when we say positive, how often are we right?"; recall asks "of the real positives, how many did we catch?"; the F1 score is their harmonic mean, punishing a model that sacrifices one for the other."

GOOD (plain lead-in + bulleted definitions):
"Using these counts, we can compute three metrics that are robust against imbalance:
- **Precision**: how often are positive labels correct?
- **Recall**: how many of the actual positives are correctly identified?
- **F1**: the harmonic mean of precision and recall, giving a more holistic metric that punishes models that sacrifice one for the other"

## Patterns to hunt and kill

1. **"makes X concrete/tangible"**, "let's make this concrete", "to see this in action" → "For example, …" / "Consider …".
2. **Anthropomorphized concepts**: "Precision asks…", "the metric wants…", "the algorithm decides it has seen enough", "the loss punishes…" (mild verbs like "penalizes" are fine in ML idiom; full dialogue-quotes inside prose are not). Metrics/functions don't *ask*, *care*, *survive*, *insist*, *complain*.
3. **Dramatic metonymy / metaphor-as-structure**: "the cure is", "the trap", "the villain", "the price of admission", "the secret", "the magic", "the trick" (when used as THE structural device; "a useful trick" in passing is fine), "the workhorse", "the engine", "the recipe".
4. **Portentous openers**: "At its core", "In essence", "Fundamentally,", "Crucially,", "Importantly,", "Notably,", "Interestingly,", "Remarkably,", "It's worth noting that", "Note that" (occasional "Note that" is fine — kill it when it starts every third paragraph).
5. **Empty intensifiers & LLM vocabulary**: "elegant", "beautiful", "powerful", "profound", "remarkable", "surprisingly simple", "deceptively simple", "leverage" (verb), "delve", "unpack", "landscape", "journey", "realm", "tapestry", "robust" as filler (keep "robust" when it's the technical meaning, as in robust statistics), "seamlessly", "effortlessly".
6. **The "not X but Y" / "not just X — it's Y" reveal**, and staccato fragments for drama: "Not a bug. A feature." Rewrite as one plain declarative sentence.
7. **Rhetorical-question chains** ("But what happens when…? And why…?") → state the fact or the problem directly. A single motivated question per section is acceptable.
8. **"This is where X comes in / enters the picture / shines"** → "X handles this:" or just introduce X.
9. **Triplet incantations** ("fast, simple, and scalable" rhythm applied everywhere) — break the rhythm; keep lists only when the items matter.
10. **Summary sentences that re-announce what was just said** ("In other words…", "Put differently…", "The takeaway is…") — keep at most one per section, and only when it adds compression (e.g. restating prose as a formula).
11. **Em-dash overuse** — this corpus should average ~6 per 1k words, not ~10. Convert em-dash asides into plain sentences or parentheses when a paragraph has more than one.
12. **"survive/punish/reward" prose economy metaphors** around math (see the user's example: "metrics that survive imbalance" → "metrics that are robust against imbalance").
13. **Hedged fake-balance filler**: "it depends on your use case", "there's no one-size-fits-all" — cut or replace with the actual criterion.
14. **Second-person coaching**: "you might wonder", "you'll notice", "don't worry if" → delete or restate as fact. Imperative voice for instructions ("score the two error types separately") is good and human.

## Preferred constructions

- Terse declaratives. Front-load the claim, then support it.
- **Definition lists / bullets with a bold term**, exactly like the GOOD example above, whenever prose enumerates 2+ named things.
- Math notation over words where it compresses ("$O(n \log n)$ versus $O(n^2)$" beats "grows much more slowly").
- "For example," / "Consider" / "To address this," / "Formally," / "In practice," as plain connectors.
- Tables for comparisons that prose is straining to hold.
- It is fine — good, even — for the rewrite to be SHORTER than the original. Never pad.

## Hard protections (do not violate)

- **NEVER edit anything inside a `$$ … $$` block that contains `\begin{tikzpicture}`** — the whole block, including its leading `%` caption comment lines. Changing one character re-keys the figure cache.
- Never edit math content inside `$…$` or `$$…$$`, code fences (``` of any language, including ```algorithm and ```tikz), frontmatter (`---` blocks), MDC markers (`:tikz-figure{…}`), or link targets.
- Do not change section headings (their anchors may be linked elsewhere). Body prose only.
- Markdown emphasis: bold `**text**`, italic `_text_`, **never** single `*`. Do not touch `*` characters inside math or code.
- Callout elements keep their exact shape: `> **Definition (Name).** …` / `> **Theorem …** …`. You may rewrite the prose *inside* them (after the bold marker) under the same rules.
- Do not add or remove figures, equations, tables, algorithms, callouts, or citations. Do not change technical claims, numbers, or notation. You are changing VOICE only — though you may restructure a paragraph into a bullet list (as in the GOOD example) since that is a voice change.
- Citations stay exactly as they are. Never introduce references to lectures, professors, or courses.
- Keep every lesson's coverage intact — trim flab, never remove content a student needs.

## Method

For each file: Read it fully, rewrite offending prose with Edit calls (several per file is normal), move on. Don't rewrite sentences that already read fine — surgical but aggressive. Expect to touch most paragraphs in the worst files and few in clean ones.
