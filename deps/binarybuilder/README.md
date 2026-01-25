# BinaryBuilder recipe (handyg)

This directory contains a `build_tarballs.jl` recipe intended to be moved to
Yggdrasil later. It adds the stable C-ABI layer (`handyg_capi.f90`) needed by
`HandyG.jl`.

Notes:
- The `BinaryBuilder.jl` toolchain currently runs under an older Julia version
  than this project (`HandyG.jl` requires Julia ≥ 1.10). Run the recipe with a
  compatible Julia version used by BinaryBuilder/Yggdrasil.
- Quad builds are not wired up yet; start with double-only across all
  platforms, then extend with a separate quad build (Windows may stay double).

