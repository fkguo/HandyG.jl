# Installation

`HandyG.jl` is a Julia wrapper around a shared library `libhandyg` built from the upstream Fortran project.

## Install the Julia package

From a Git repository (GitHub/GitLab/…):

```julia
using Pkg
Pkg.add(url="https://github.com/fkguo/HandyG.jl.git")
```

## Provide `libhandyg`

### Option A: local build (developer workflow)

This repo includes a helper script that builds a development copy into `deps/usr/lib/`:

```bash
# expects the upstream handyG repo as a sibling: ../handyg
bash deps/build_local.sh
```

Tested with upstream tag `v0.2.0b` (commit `756ab007b4655e0b37244dd0dcc072f3ae7f4bc8`).

If your upstream source lives elsewhere:

```bash
export HANDYG_SRC=/path/to/handyG/src
bash deps/build_local.sh
```

### Option B: `HANDYG_LIB` environment variable

You can point directly at a prebuilt library:

```bash
export HANDYG_LIB=/abs/path/to/libhandyg.so   # Linux
export HANDYG_LIB=/abs/path/to/libhandyg.dylib # macOS
export HANDYG_LIB=C:\\path\\to\\libhandyg.dll  # Windows
```

### Option C: JLL (BinaryBuilder/Yggdrasil) (in progress)

We are working towards a `HandyG_jll` package published through Yggdrasil so end users do not
need a Fortran toolchain.

- Yggdrasil PR (CI green): https://github.com/JuliaPackaging/Yggdrasil/pull/13008

Once that is merged and released, this will become the recommended install path. Until then,
use Option A or B.

## Build the docs locally

```bash
julia --project=docs -e 'using Pkg; Pkg.develop(PackageSpec(path=pwd())); Pkg.instantiate(); include("docs/make.jl")'
```
