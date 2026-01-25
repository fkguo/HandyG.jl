# Installation

`HandyG.jl` is a Julia wrapper around a shared library `libhandyg` built from the upstream Fortran project.

## Install the Julia package

From a Git repository (GitHub/GitLab/…):

```julia
using Pkg
Pkg.add(url="https://github.com/fkguo/HandyG.jl.git")
```

For private access via SSH:

```julia
using Pkg
Pkg.add(url="git@github.com:fkguo/HandyG.jl.git")
```

## Provide `libhandyg`

### Option A: local build (developer workflow)

This repo includes a helper script that builds a development copy into `deps/usr/lib/`:

```bash
# expects the upstream handyG repo as a sibling: ../handyg
bash deps/build_local.sh
```

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

### Option C: JLL (BinaryBuilder/Yggdrasil) (planned)

The intended end state is a `*_jll` package published through Yggdrasil so end users do not need a Fortran toolchain. Until that is in place, use Option A or B.

## Build the docs locally

```bash
julia --project=docs -e 'using Pkg; Pkg.develop(PackageSpec(path=pwd())); Pkg.instantiate(); include("docs/make.jl")'
```
