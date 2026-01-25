# Performance Notes

## Allocation-free hot paths

After Julia compilation warmup, the following are designed to run without heap allocations:

- `G(...)` scalar calls
- `G!(out, ...)` scalar calls into a preallocated `Ref{ComplexF64}`
- `G_batch!(out, ...)` batched calls into a preallocated output vector

For high-throughput use, prefer `G_batch!` and reuse all buffers.

## Recommended default: non-`Cint` integers with zero allocations (after warmup)

The C ABI expects `m`/`len` as `Cint` (`Int32`) for correctness. For convenience, `HandyG.jl`
accepts `Vector{Int}` (or other integer types) and converts them internally.

To keep this conversion allocation-free in steady state:

- Make the integer arrays persistent (e.g. `const` globals or reused buffers)
- Call the relevant function once during initialization to let internal scratch buffers size

Example (condensed form):

```julia
using HandyG

const m = [1, 2]               # Vector{Int}
const z = [1.0, 0.5]
const y = 0.3

# warmup (compiles + sizes internal scratch)
G(m, z, y)

# steady-state: no allocations from the `m` conversion
@assert (@allocated G(m, z, y)) == 0
```

Example (batch `len`):

```julia
using HandyG

const len = [4, 3]   # Vector{Int}

# warmup
out = Vector{ComplexF64}(undef, 2)
g = zeros(Float64, 4, 2)
G_batch!(out, g, len)

# steady-state
@assert (@allocated G_batch!(out, g, len)) == 0
```

Notes:

- If the internal scratch buffer needs to grow (e.g. you later pass a longer `m`/`len`), a
  one-time allocation can occur at that moment. Pre-warm with the maximum expected length to
  avoid this.
- For absolute clarity and predictability in tight loops, passing `Cint[...]` / `Vector{Cint}`
  is still the “gold standard”, but the above pattern is a good default for ergonomic code.

## Input layout

For batch calls, use fixed-depth `(depth_max, N)` matrices with a `len::Vector{Cint}` per column.

This avoids:

- per-call allocations
- ragged array overhead
- pointer chasing and cache misses from “array of vectors”

## Parallelism

The underlying Fortran library maintains global runtime options and caches. This generally implies the library is **not re-entrant** under Julia threads.

Recommended strategies:

- Use `G_batch!` to maximize single-call throughput.
- For true parallel scaling, prefer **multi-process** parallelism (`Distributed`), where each process has its own `libhandyg` state.
