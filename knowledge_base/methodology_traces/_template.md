# Methodology Trace

Purpose:
- Record **method selection** (candidate comparison + decision rationale) before implementing complex algorithms (no brute-force).
- Record **search provenance** (INSPIRE/arXiv/GitHub only) and link to local KB notes.
- Preserve a reproducible **execution/evidence trail** for future reuse.

Link policy:
- Links must be clickable. Do NOT wrap Markdown links or citations like [@recid-...](#ref-recid-...) in backticks.

## Metadata

- Date:
- Tag (milestone/round):
- Mode/Profile:
- Owner:
- Scope: (what this trace covers / what it does NOT cover)

## Problem statement (what we are trying to compute/decide)

- Goal:
- Inputs:
- Outputs:
- Constraints: (accuracy, runtime, stability, licensing, dependencies)

## Candidate methods (compare before implementing)

Minimum expectation for nontrivial numerics/algorithms: list **>=2** candidates and justify the choice.

| Candidate | Source(s) (external link + local KB note link) | Pros | Cons / Risks | Complexity / Cost | Decision |
|---|---|---|---|---|---|
| Method A |  |  |  |  | selected / rejected |
| Method B |  |  |  |  | selected / rejected |

Notes:
- If a brute-force approach is considered, record it here and state explicitly why it is rejected (or why it is acceptable for a specific, bounded audit slice only).

## Decision (chosen approach)

- Chosen method:
- Why chosen (evidence-based):
- What would falsify this choice? (failure mode / instability signal)
- Fallback plan:

## Search log (INSPIRE/arXiv/GitHub; mandatory when expanding KB)

Append-only query log (create if missing): [literature_queries.md](literature_queries.md)

Record at least:
- query string
- filters/selection criteria
- what you accepted/rejected and why
- links to the local KB notes you created/updated

| Timestamp | Source | Query | Shortlist (links) | Decision / Notes |
|---|---|---|---|---|
|  | INSPIRE / arXiv / GitHub |  |  |  |

## Execution log (what was run and what it produced)

| Step | Input | Output | Decision |
|---|---|---|---|
| 1 |  |  |  |

## Reuse / extraction (optional but recommended)

- Reusable artifact(s) produced: (code pointers / modules / scripts)
- API surface (if any): (link to API doc, or list functions/signatures)
- What future projects can reuse:

## Deviations

- Deviation:
- Reason:
- Impact:

## Evidence

- Files:
- Commands:
