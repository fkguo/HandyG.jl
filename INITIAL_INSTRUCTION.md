# INITIAL_INSTRUCTION.md

## 项目目标（Goal）

将 Fortran 版 **handyG**（generalised polylogarithms 数值库）封装为 Julia 程序包 **HandyG.jl**，满足：

1) **跨平台一键安装**：macOS / Linux / Windows 均可用；合作者可通过 GitHub URL 直接 `Pkg.add(url=...)` 安装后运行示例与测试，不需要本机安装 gfortran/编译链。
2) **精度双后端**：支持 upstream 的 `--quad`（quadruple precision）与默认 double precision，两套二进制均可安装/切换。
3) **API 贴近 Fortran 习惯**：优先提供与 upstream 近似的调用形态（含 “superflat” 形态），并支持 `i0±` 分支割线控制。
4) **并行与性能优先**：给出可复现的并行方案（至少多进程；线程并行若受 upstream 全局缓存影响需明确约束或给出线程安全实现），并提供性能基准/建议。
5) **必须提供批量接口**：实现 `G!(out, ...)` / `G_batch!(...)`（或等价命名）以支持大规模点集计算；在预热后批量热路径应为 **0 allocations**。

## 代码范围（Scope）

- Julia 绑定 repo：本目录（HandyG.jl）。
- Upstream 源码在兄弟目录 [../handyg](../handyg)（Fortran 源 + `./configure && make`）。
- 允许对 upstream 做“最小侵入”补丁（例如新增 `ISO_C_BINDING` 的 C ABI wrapper），但不重写数学核心算法。

## 分发策略（Distribution）

- **必须使用 BinaryBuilder/JLL** 作为主线分发方案（跨平台一键安装的必要条件）。
- 允许在早期阶段保留 “本地编译 fallback（开发者用）”，但任何里程碑都要优先保证：合作者无需编译即可安装使用。
- BinaryBuilder 产物成熟后可提交到 Yggdrasil：`https://github.com/JuliaPackaging/Yggdrasil`（作为后续里程碑）。
  - 说明：若走 Yggdrasil，通常**无需手动创建** `HandyG_jll.jl` repo；Yggdrasil 合并后会自动生成/发布对应的 `*_jll` 包。
  - 在提交 Yggdrasil 之前的团队测试阶段：优先用 GitHub Actions + BinaryBuilder 生成 tarballs，挂到本 repo 的 GitHub Releases，并通过 `Artifacts.toml` 引用，实现 `Pkg.add(url=...)` 一键安装测试。

## 技术路线（High-level Technical Strategy）

### A) 稳定 ABI（避免直接依赖 Fortran module 符号）

- 在 upstream 侧新增一个 C ABI 层（Fortran `ISO_C_BINDING` + `bind(C)`），导出稳定符号供 Julia `ccall`。
- **避免** `complex` 作为函数返回值（跨 ABI 风险大）：用 `subroutine` + `intent(out)` 输出 `res_re/res_im`。
- 输入参数显式化：权重与 `y` 用 “实部数组 + 虚部数组 + i0 数组” 传递；减少 Fortran derived type 穿透到 C/Julia 的风险。
  - Julia API 需要覆盖：`superflat` + `flat` + `condensed` 三种调用形态，但 **Julia 侧只暴露一个函数名 `G`**（利用多重分派），通过不同签名区分：
    - `G(g)`：superflat（`g[end]` 为 `y`）
    - `G(z, y)`：flat
    - `G(m, z, y)`：condensed
  - 为避免 Julia 侧构造 `z_flat` 导致分配，`condensed` 建议直接走 C ABI wrapper（在 Fortran wrapper 内部调用 `G_condensed`），从而保证 Julia 热路径 **0 allocations**。
  - Julia 侧零分配策略：
    - 仅接受 `StridedVector`/标量等不会触发隐式复制的输入；对非连续 `view` 等输入直接报错（避免“悄悄 copy”带来的隐式分配）。
    - `i0±` 采用 SoA（例如 `z::Vector{ComplexF64}` + `z_i0::Vector{Int8}`）作为性能路径；不依赖 Fortran derived type 的内存布局。
  - ABI 验收门槛：先提供一个最小 `test_abi.c`（C 调用 Fortran 动态库）在 CI 跑通；C 能跑通后再做 Julia 绑定，避免把 ABI 问题混进 Julia 调试。

### B) 双精度/四精度并存

- double 与 quad 分别编译为不同 artifact（或不同库名），Julia 侧提供选择机制（例如按输入类型或显式参数选择）。
- quad 依赖 `libquadmath`；Julia 侧预计需要 `Quadmath.jl` 来提供 `Float128`（可按可行性评估调整）。

### C) 并行语义

- 预期 upstream 含全局缓存/状态（例如 GPL cache 与 options），默认**非线程安全**。
- 首选并行路径：Julia `Distributed` 多进程（每进程独立状态，性能/正确性更可控）。
- 线程并行：作为里程碑评估项；若要支持，需要给出可证明的线程隔离方案（例如 threadprivate/OpenMP 或上下文对象化），否则文档明确限制并提供推荐替代方案。

## 验收标准（Definition of Done）

- correctness：Julia 端复现 upstream README 示例数值（double：~1e-10；quad：更严格阈值待定），并覆盖 `i0±` 分支割线测试。
- packaging：macOS/Linux/Windows 上 `Pkg.add(url=...)` 后可直接 `using HandyG` 并运行 `Pkg.test` 全通过（无需本机编译链）。
- parallel：提供可复现的并行样例与一致性测试（至少多进程；线程若支持则提供压力测试）。
- performance：关键调用路径（`G(g)` / `G(z,y)` / `G(m,z,y)`）在 Julia 侧应达到 **0 allocations**（用 `@allocated`/`BenchmarkTools` 验证；允许首次加载/编译期分配）。
- hygiene：项目完成后再清理 research-team 规划文件；开发阶段保留以便规划/分工/审查。

Recommended next step (human review):
- 根据 `RESEARCH_PLAN.md` 审查里程碑与验收标准，并确认：
  - quad 是否要求 Windows 覆盖（允许 “Windows 仅 double” 作为临时策略）
  - API 必须覆盖：`superflat` + `flat` + `condensed`（均以 `G` 多分派提供）；请确认偏好的签名是否如上
