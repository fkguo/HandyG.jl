# GPL Definitions and Notation

This page defines the generalized polylogarithms (GPLs) evaluated by the upstream
Fortran library **handyG**, and maps the mathematical notation to the concrete
calling conventions in `HandyG.jl`.

The conventions below follow Naterop, Signer, Ulrich, *handyG --- rapid numerical
evaluation of generalised polylogarithms* (arXiv:1909.01656), Section 2.

## Mathematical definition (flat form)

A GPL (Goncharov polylogarithm) is a complex-valued function of parameters
`z_1, ..., z_m` and an argument `y`. For ``z_m \neq 0``, it can be defined as the
iterated integral:

```math
G(z_1,\ldots,z_m; y) \equiv
\int_0^y \frac{\mathrm{d}t_1}{t_1-z_1}
\int_0^{t_1} \frac{\mathrm{d}t_2}{t_2-z_2}
\cdots
\int_0^{t_{m-1}} \frac{\mathrm{d}t_m}{t_m-z_m}.
```

Equivalently, in recursive form (still requiring ``z_m \neq 0``),

```math
G(z_1,\ldots,z_m; y) =
\int_0^y \frac{\mathrm{d}t}{t-z_1}\,G(z_2,\ldots,z_m; t)
```

For weight 1 with ``z \neq 0`` this reduces to a logarithm:

```math
G(z; y) = \log\left(1-\frac{y}{z}\right).
```

In the wider GPL literature, the equivalent convention ``G(; y) = 1`` (empty
parameter list) is also used as a recursion base case; the two presentations are
equivalent.

To cover the all-zero case, we define

```math
G(\underbrace{0,\ldots,0}_{m}; y) = \frac{(\log y)^m}{m!}.
```

Notes:

- In practice, `handyG` accepts parameter lists that contain zeros and handles the
  required regularisation/transformations internally.
- GPLs are multi-valued; see the [`i0±` Prescription](i0.md) page for how to make
  branch choices explicit at real points on branch cuts.

## Condensed notation (zero compression)

If many parameters are zero, the paper (and upstream code) also uses a condensed
notation that compresses runs of zeros into integer partial weights.

Let `m_1, ..., m_k` be positive integers. A depth-`k` GPL in condensed notation is
defined by expanding back to a flat parameter list:

```math
G_{m_1,\ldots,m_k}(z_1,\ldots,z_k; y)
\equiv
G(\underbrace{0,\ldots,0}_{m_1-1}, z_1,
  \underbrace{0,\ldots,0}_{m_2-1}, z_2,
  \ldots,
  \underbrace{0,\ldots,0}_{m_k-1}, z_k; y).
```

The total weight is ``m = \sum_{i=1}^k m_i``.

The **depth** `k` is the number of non-zero parameters (not counting `y`), i.e.
the length of the condensed parameter lists.

## Mapping to `HandyG.jl`

`HandyG.jl` keeps the upstream calling conventions and implements them via
multiple dispatch. In all cases, the mathematical `G(\cdots; y)` is evaluated at
numeric inputs and returned as a `ComplexF64` (this wrapper is currently
double-precision only).

### Scalar `G`

1. **Superflat** (upstream interface encoding)

   - Julia: `G(g)` with `g = [z..., y]`
   - Math: `G(z_1,\ldots,z_m; y)` with `z_i = g[i]` for `i=1..m` and `y = g[m+1]`

   This is a compact encoding used by the upstream interface; the last entry is
   always `y`.

2. **Flat**

   - Julia: `G(z, y)` with `z = [z_1, ..., z_m]`
   - Math: `G(z_1,\ldots,z_m; y)`

3. **Condensed**

   - Julia: `G(m, z, y)` with `m = [m_1, ..., m_k]` and `z = [z_1, ..., z_k]`
   - Math: `G_{m_1,\ldots,m_k}(z_1,\ldots,z_k; y)`

   Requirements:

   - `length(m) == length(z)`
   - `m_i >= 1` for all used entries

   Example (expansion to flat parameters):

   - Julia: `m = Cint[1, 2]`, `z = [1.0, 0.5]`
   - Math: `G_{1,2}(1, 0.5; y) = G(1, 0, 0.5; y)`

### In-place `G!`

`G!(out::Ref{ComplexF64}, args...)` evaluates a single GPL and writes to `out[]`.
The supported argument shapes are the same as for `G(...)` (superflat / flat /
condensed, including `inum` inputs).

If `out` is a vector, `G!(out, ...)` dispatches to [`G_batch!`](batch.md).

### Batch `G_batch!`

`G_batch!` evaluates `N` independent GPLs at once. Inputs are fixed-depth
column-major matrices `(depth_max, N)` plus a `len` vector that indicates how
many entries in each column are active.

1. **Superflat batch**

   - Julia: `G_batch!(out, g, len)` where `g` is `(depth_max, N)`
   - Column `j` evaluates

     ```math
     G(g_{1j},\ldots,g_{(\ell_j-1)j}; g_{\ell_j j}),
     \qquad \ell_j = \mathrm{len}[j].
     ```

2. **Flat batch**

   - Julia: `G_batch!(out, z, y, len)` where `z` is `(depth_max, N)` and
     `y` is a length-`N` vector
   - Column `j` evaluates

     ```math
     G(z_{1j},\ldots,z_{\ell_j j}; y_j),
     \qquad \ell_j = \mathrm{len}[j].
     ```

3. **Condensed batch**

   - Julia: `G_batch!(out, m, z, y, len)` where `m` and `z` are both `(depth_max, N)`
   - Column `j` evaluates

     ```math
     G_{m_{1j},\ldots,m_{\ell_j j}}(z_{1j},\ldots,z_{\ell_j j}; y_j),
     \qquad \ell_j = \mathrm{len}[j].
     ```

For explicit `i0±` prescriptions in either scalar or batch form, use the
[`inum` helper](i0.md) to construct `INum`, `INumVec`, `INumMat` inputs, then
call the same `G`/`G!`/`G_batch!` entry points.
