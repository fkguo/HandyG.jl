# RESEARCH_PLAN.md (Template)

Project: HandyG.jl
Owner: fkg + collaborators
Created: 2026-01-25
Last updated: 2026-01-25

## Execution Trigger (Prework -> Team Cycle)

Prework checklist (must complete before any team cycle):
- Populate [knowledge_base/literature/](knowledge_base/literature/) with at least 1 note
- Populate [knowledge_base/methodology_traces/](knowledge_base/methodology_traces/) with at least 1 trace
- Update [knowledge_base/priors/](knowledge_base/priors/)
- Update Capsule I) in [Draft_Derivation.md](Draft_Derivation.md) with all paths

Run preflight (no external LLM calls):

```bash
bash ~/.codex/skills/research-team/scripts/bin/run_team_cycle.sh \
  --tag M0-r1 \
  --notes Draft_Derivation.md \
  --out-dir team \
  --member-a-system prompts/_system_member_a.txt \
  --member-b-system prompts/_system_member_b.txt \
  --auto-tag \
  --preflight-only
```

Run full team cycle (Claude + Gemini):

```bash
bash ~/.codex/skills/research-team/scripts/bin/run_team_cycle.sh \
  --tag M0-r1 \
  --notes Draft_Derivation.md \
  --out-dir team \
  --member-a-system prompts/_system_member_a.txt \
  --member-b-system prompts/_system_member_b.txt \
  --auto-tag
```

## 0. Goal (What / Why)

- One-sentence objective: 将 upstream Fortran `handyG` 封装为跨平台可一键安装的 Julia 包 `HandyG.jl`（double+quad），并提供与 Fortran 接近的 API、可复现的并行与性能基准。
- Why it matters: 让团队在 Julia 科学计算工作流中直接调用 GPL 数值库，避免各平台 Fortran 编译环境差异导致的不可复现与安装门槛。
- Primary deliverables:
  - Julia 包源码：`src/` + `test/` + `README.md`
  - BinaryBuilder 产物：artifacts（早期）/ 未来可迁移为 JLL 并提交 Yggdrasil
  - 上游补丁：最小侵入的 C ABI wrapper（便于复现与维护）

## 1. Scope (SCOPE)

- In scope:
  - 稳定 C ABI（Fortran `ISO_C_BINDING` + `bind(C)` wrapper）
  - Julia 侧 API（贴近 Fortran：superflat/flat；支持 `i0±`；暴露 `set_options!/clearcache!`）
  - BinaryBuilder 交叉编译与 artifacts 下载（macOS/Linux/Windows）
  - double + quad 两套后端（`--quad`）
  - 并行语义与性能基准（至少多进程并行；线程并行作为可行性里程碑）
- Out of scope（除非后续追加需求）:
  - 重写/优化 upstream 数学算法
  - 发布到 General registry（可选）
  - 复杂符号化接口（Mathematica/GiNaC 等）
- Explicit limitations:
  - upstream 内部有全局缓存/状态：若无法在合理成本内做到线程安全，将以多进程并行为主，并在文档中明确限制与推荐替代方案。

## 2. Claims & Falsification

List the claims you want to be able to defend, and what would falsify them.

- Claim C1（Correctness / Double）: 对选定测试点集，`HandyG.jl`（double）输出与 upstream reference 一致（在容差内）。
  - Evidence needed: `test/` + CI 记录；最少包含 README 示例与 upstream 自带测试子集。
  - Falsified if: 在相同输入下误差超阈值，且无法用已知数值误差/分支语义解释。
- Claim C2（Correctness / Quad）: quad 后端可用，并在代表性输入上相对 double 提升有效位。
  - Evidence needed: quad 测试点集 + 与高精 reference（或与 double 对比 + 稳定性诊断）。
  - Falsified if: quad 在目标平台不可构建或结果不稳定/无提升。
- Claim C3（Installability）: macOS/Linux/Windows 上通过 GitHub URL 安装后可直接运行（无需 gfortran）。
  - Evidence needed: CI 安装测试（`Pkg.add(url=...)` + `Pkg.test`）。
  - Falsified if: 任一平台需要本机编译链或 artifacts 下载/加载失败。
- Claim C4（Parallel usability）: 提供可复现的并行方式（至少多进程），结果与单进程一致（容差内）。
  - Evidence needed: `examples/` 或 `test/` 中并行一致性测试。
  - Falsified if: 并行导致崩溃/死锁/结果不一致且无法规避。

## 2.5 Innovation Maximization (Idea Portfolio)

To avoid “only minimum deliverables”, maintain an explicit idea portfolio:
- Create/maintain [INNOVATION_LOG.md](INNOVATION_LOG.md) (template provided by this skill).
- Each idea must be falsifiable and include a discriminant diagnostic, a minimal test, and a kill criterion.
- At each milestone, run 1–2 quick “innovation sprints” (low-res is fine) to advance/kill ideas fast.

## 3. Definition-Hardened Quantities (Contract)

For each quantity, lock:
1) exact operational definition,
2) code symbol + file path,
3) how uncertainty is estimated.

| Quantity | Operational definition | Code pointer | Uncertainty |
|---|---|---|---|
| H1_double | README 示例中某个 `G(...)` 数值输出（double） | `test/`（待实现） | abs/rel tol（待定） |
| H1_quad | 同一输入的 quad 输出 | `test/`（待实现） | abs/rel tol（待定） |
| Install_OK | `Pkg.add(url=...); using HandyG` 成功 | CI workflow（待实现） | N/A |
| Parallel_OK | 多进程并行一致性检查通过 | `test/`（待实现） | 容差同上 |

## 4. Reproducibility Artifact Contract

Best practice (recommended) artifact contract (especially for computational/dataset milestones):
- Run manifest JSON: command + params + versions + outputs
- Summary JSON/CSV: computed statistics used for plots/tables
- Analysis JSON/CSV: headline quantities recomputed from raw artifacts
- Main figures: generated and embedded in [Draft_Derivation.md](Draft_Derivation.md) (not just saved to disk)

Preferred numerics language:
- Default: Julia (aim for type-stable, preallocated hot loops; use mature packages first)
- Optional: Python (when ecosystem/tools make it clearly simpler); consider PyCall only when it improves workflow

Minimum gate enforced by this skill (hard fail-fast):
- [Draft_Derivation.md](Draft_Derivation.md) Capsule is complete, outputs exist on disk, headline pointers are machine-extractable,
- and (by default) at least one data artifact + at least one main figure embedded in the notebook (unless `Milestone kind: theory` or `dataset` rules apply).

Minimum fields (edit per project):
- manifest: `created_at`, `command`, `cwd`, `git`, `params`, `versions`, `outputs`
- summary: `definitions`, `windowing`, `stats`, `outputs`
- analysis: `inputs`, `definitions`, `results`, `uncertainty`, `outputs`

## 5. Milestones

Each milestone must have:
- **deliverables** (paths)
- **acceptance tests** (how to verify; must be concrete, not “looks good”)
- **team gate** (two-member independent cross-check + convergence)
- **innovation delta** (what new falsifiable insight/diagnostic was added)
- **methodology traces** (what validated method/evidence was preserved for reuse)
- **toolkit delta** (ONLY when `profile=toolkit_extraction`: enforce reusable API + code index + KB linkage)

### Definition of Done (DoD) rubric (anti-superficial)

Acceptance MUST be evidence-backed and quickly checkable:
- Prefer **file/field pointers** (e.g. `artifacts/analysis.json:results.foo`) over prose.
- Prefer **thresholds** (e.g. `<= 1e-6`) over “reasonable”.
- Prefer **explicit gate names/commands** (e.g. `run_team_cycle.sh --preflight-only`) over “passed checks”.
- If full recomputation is impractical, define **audit proxy headlines** (fast-to-check quantities) and record them in:
  - [Draft_Derivation.md](Draft_Derivation.md) → Audit slices block
  - Team packet → “Audit slices / quick checks”

## Task Board (autopilot uses this)

- [ ] T0: (auto) 在 GitHub 创建 `HandyG.jl` private repo 并推送（含 CI）
- [ ] T1: (auto) 冻结需求：平台/quad 覆盖范围/API 最小集/并行策略（Windows 允许临时仅 double）
- [ ] T2: (auto) 上游审计：全局状态/缓存/线程安全风险清单（含代码指针）
- [ ] T3: (auto) 设计 `docs/ABI.md`（C ABI：double+quad；error model；避免 complex 返回值）
- [ ] T4: (auto) 设计 `docs/API.md`（Julia 多分派：统一函数名 `G` 覆盖 superflat/flat/condensed；0-allocation 热路径 + 必做批量 `G!`/`G_batch!`）
- [ ] T4b: (auto) 确定性能路径输入形态：仅 `StridedVector`；`i0±` 用 SoA（`Complex` 数组 + `Int8` i0 数组）；禁止隐式 copy
- [ ] T5: (auto) 实现 upstream C ABI wrapper（double）+ 本地 smoke test
- [ ] T5b: (auto) C 级 ABI 冒烟测试（`test_abi.c`）：先用 C 调通库再上 Julia（CI 三平台）
- [ ] T6: (auto) Julia `ccall` bindings + README 示例（double；`G` 多分派覆盖 superflat/flat/condensed；热路径 0 allocations）
- [ ] T7: (auto) BinaryBuilder recipe（double）+ `Artifacts.toml` 集成 + CI 三平台
- [ ] T8: (auto) quad 可行性验证（Linux/macOS/Windows 分别给结论；Windows 允许临时仅 double）
- [ ] T9: (auto) quad artifacts + Julia quad API（若可行）
- [ ] T10: (auto) 并行一致性测试：Distributed（必做）+ Threads（若支持）
- [ ] T11: (auto) 性能基准与优化：减少分配/批量接口/worker pool（按 profiling 决定）
- [ ] T12: (auto) 准备 Yggdrasil PR（可选）

## Progress Log

- <YYYY-MM-DD> tag=<TAG> status=<converged|not_converged> task=<Tn> note=<short>

### M0 — 需求冻结 + 设计合同（API/ABI/并行）

- Deliverables (paths):
  - `docs/API.md`（Julia API 草案：统一函数名 `G` 的多分派签名 + i0/options/cache；声明 0-allocation 约束）
  - `docs/ABI.md`（C ABI 草案：函数签名 + 类型布局 + error codes）
  - `docs/Parallel.md`（并行策略：多进程为主；线程策略评估与约束）
- Acceptance:
  - 明确回答：quad 是否必须覆盖 Windows；若暂不覆盖，给出清晰的降级/报错行为与后续路线
  - 定义最小 API 覆盖清单（必须包含：`G(g)` / `G(z,y)` / `G(m,z,y)`；并明确 `condensed` 走专用 C ABI wrapper，避免 Julia 侧 flatten 分配）
  - 定义最小测试点集（double/quad/i0）与误差阈值
  - 定义性能门槛：热路径 `G(...)` 在 Julia 侧 **0 allocations**（以 `@allocated`/`BenchmarkTools` 为准；排除首次编译/加载）
  - 明确“无隐式分配”策略：对非 `StridedVector` 输入报错（而不是内部 `collect/copy`）

### M1 — C ABI wrapper + 本地调用打通（double）

- Deliverables:
  - upstream patch：新增 Fortran `ISO_C_BINDING` wrapper（不侵入算法核心）
  - 本地生成 `libhandyg_julia`（macOS）+ Julia `ccall` smoke test
  - `test/abi/test_abi.c`（C 级 ABI 测试程序；用于在 CI 上提前捕获 ABI/导出符号问题）
- Acceptance:
  - README 示例点（double）一致（容差见 M0）
  - i0± 参数可从 Julia 传入并影响分支结果（至少 1 个专门测试）
  - `test_abi.c` 在至少 macOS/Linux 上运行通过；Windows 若受工具链限制则给出等价替代（例如 MinGW/clang + import lib）

### M2 — BinaryBuilder 产物（double）+ GitHub 一键安装

- Deliverables:
  - `deps/binarybuilder/build_tarballs.jl`（或同等路径）
  - `Artifacts.toml` + 自动下载/加载逻辑（无需 gfortran）
  - CI：macOS/Linux/Windows 的安装 + 测试
- Acceptance:
  - 三平台上 `Pkg.add(url=...)` 后 `Pkg.test` 通过（无需本机编译链）
  - artifacts 校验（sha256）一致；库加载路径稳定

### M3 — quad 构建与 API（跨平台可行性里程碑）

- Deliverables:
  - quad 版本 artifacts（至少 Linux/macOS；Windows 视可行性结论）
  - Julia 侧 quad 类型/调用路径（预计 `Quadmath.jl`）
- Acceptance:
  - quad 后端在至少一个平台可用并通过测试点集
  - 对代表性点：quad 相比 double 的结果稳定且有效位提升（阈值见 M0）
  - 若 quad 在 Windows 不可行：明确记录 “Windows 仅 double（临时）”，并保证 Windows 端行为清晰（禁用/报错/自动降级策略在文档中固定）

### M4 — API 完整化 + 文档（贴近 Fortran）

- Deliverables:
  - 完整 API：`set_options!`, `clearcache!`, `G`（多分派覆盖 superflat/flat/condensed；以及必要的输入类型变体）
  - 批量接口（必须实现）：`G!(out, ...)` 或 `G_batch!(...)`（用于大规模计算避免任何临时分配）
  - `README.md`：安装（GitHub）+ 选择 double/quad + 并行建议 + 示例
- Acceptance:
  - API 覆盖 M0 冻结清单；文档中的示例可直接运行
  - `@allocated` 断言：关键 `G(...)` 方法在预编译/预热后为 0（或记录例外与修复计划）
  - 批量接口在代表性规模下为 0 allocations（预热后），并提供基准脚本与结果记录

### M5 — 并行/性能交付（并行一致性 + 基准）

- Deliverables:
  - 多进程并行示例/测试（`Distributed`）
  - 线程策略结论：若支持则提供实现与测试；若不支持则提供明确限制与推荐替代方案
  - 性能基准脚本（至少 1 个热点场景）
- Acceptance:
  - 并行一致性测试通过（容差内）
  - 给出可复现 benchmark 输出与结论（含建议参数/注意事项）
  - 性能回归门禁：基准脚本在 CI（或本地记录）中可比对，避免后续改动引入分配/性能退化

### M6 —（可选）Yggdrasil 提交

- Deliverables:
  - Yggdrasil recipe PR（HandyG / handyg wrapper）
- Acceptance:
  - PR 通过 CI（或明确列出阻塞项与解决路线）

## 6. Team Loop (How we work like a team)

At the end of each milestone:
1) Update [INNOVATION_LOG.md](INNOVATION_LOG.md) (advance/revise/kill ideas; write the milestone’s innovation delta)
2) Build a team packet (`prompts/team_packet_<TAG>.txt`)
3) Run a team cycle (Claude + Gemini; both do both)
4) Convert findings into a fix list
5) Apply fixes and re-run checks
6) **Convergence gate**: if either report says mismatch/fail/needs revision, re-run (new tag, e.g. `M2-r1`) until both pass
7) Mark milestone complete only after convergence
