# knowledge_base

This folder stores evidence and priors used by the project. It is required before any team cycle.

## literature/

- Notes and excerpts from primary sources
- One file per topic or paper cluster
- Include a `RefKey: <Key>` line near the top of each note (used in [Draft_Derivation.md](../Draft_Derivation.md) references).
- For INSPIRE-based notes, also include:
  - `INSPIRE recid: <integer>`
  - `Citekey: <texkey>`
  - `Authors: <FirstAuthor et al.>`
  - `Publication: <journal / arXiv / status>`
- Include an external link if available (prefer INSPIRE/arXiv/DOI; GitHub is allowed for code).
- Markdown math hygiene (rendering safety):
  - Use `$...$` / `$$...$$` (do not use `\(` `\)` `\[` `\]`).
  - In `$$...$$` blocks, no line may start with `+`, `-`, or `=` (prefix with `\quad`).
  - Do not split one multi-line equation into back-to-back `$$` blocks; keep one `$$...$$` block.
  - Deterministic autofix helper: `python3 ~/.codex/skills/research-team/scripts/bin/fix_markdown_math_hygiene.py --root knowledge_base --in-place`

## methodology_traces/

Validated procedures and reproducibility traces:
- short summaries of what was checked
- commands and outputs
- known limitations
- algorithm-search notes and stability decisions for numerics
- append-only query log (created by scaffold): [literature_queries.md](methodology_traces/literature_queries.md)

## priors/

Project conventions and fixed assumptions:
- notation
- normalization
- units
- known constraints
