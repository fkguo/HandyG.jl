# Performance Notes

## Allocation-free hot paths

After Julia compilation warmup, the following are designed to run without heap allocations:

- `G(...)` scalar calls
- `G!(out, ...)` scalar calls into a preallocated `Ref{ComplexF64}`
- `G_batch!(out, ...)` batched calls into a preallocated output vector

For high-throughput use, prefer `G_batch!` and reuse all buffers.

Convenience overloads that accept `m`/`len` as `Vector{Int}` (or `i0` as `Vector{Int}`) allocate temporary conversion buffers; avoid them in performance-critical loops.

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
