# PROJECT_CHARTER.md

Status: DRAFT  # change to APPROVED after human review
Project: HandyG.jl
Root: ../HandyG.jl
Created: <YYYY-MM-DD>
Last updated: <YYYY-MM-DD>

## 0. Goal Hierarchy (MANDATORY)

Primary goal: (fill; the real goal, e.g. "layered knowledge base + reusable toolkit/components")

Validation goal(s): (fill; e.g. "reproduce target figure/table/result X as validation only")

Anti-goals / non-goals (must include at least 1):
- (fill; e.g. "do NOT optimize for validation-only progress without reusable extraction")

## 1. Declared Profile (MANDATORY)

Declared profile: mixed
Rationale: (fill; why this profile matches the goal hierarchy)

## 2. Reusable Outputs Contract (MANDATORY)

For every milestone/cycle, the project must produce at least one reusable delta beyond validation-only work:
- KB delta: at least 1 new/updated note under [knowledge_base/](knowledge_base/) (and referenced from Capsule I and `## References`)
- Methodology delta: at least 1 new/updated item under [knowledge_base/methodology_traces/](knowledge_base/methodology_traces/) with candidate methods + selection rationale
- Toolkit delta (if applicable): a reusable module/API/doc index (e.g. [TOOLKIT_API.md](TOOLKIT_API.md), `src/`, `toolkit/`)

Project-specific commitments (fill at least 2 bullets; must include at least 1 KB link):
- (fill; KB: e.g. [recid-XXXX](knowledge_base/literature/recid-XXXX.md) — normalization audit notes)
- (fill; Method: e.g. [method choice](knowledge_base/methodology_traces/2026-01-19_method_choice.md) — candidate algorithms + why chosen)
- (fill; Toolkit: e.g. `toolkit/` module list + entrypoint plan; or [TOOLKIT_API.md](TOOLKIT_API.md))

## 3. Discovery Policy (MANDATORY)

- Allowed sources for discovery: INSPIRE-HEP + arXiv + GitHub (no general web search; no other domains).
- Log all queries + selection decisions in [knowledge_base/methodology_traces/literature_queries.md](knowledge_base/methodology_traces/literature_queries.md).

## 4. Task Alignment (RECOMMENDED)

To prevent drift, every Task Board entry should clearly state which top-level goal it advances:
- `[KB]` expands layered knowledge base
- `[TOOLKIT]` extracts reusable code/API/docs
- `[VALIDATION]` validates against a target result (must not be the only ongoing work)
- `[DOC]` narrative/derivation quality and reference hygiene
