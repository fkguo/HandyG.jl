# Installation

`HandyG.jl` is a Julia wrapper around a shared library `libhandyg` built from the upstream Fortran project.

## Install the Julia package

From a Git repository (GitHub/GitLab/…):

```julia
using Pkg
Pkg.add(url="https://github.com/fkguo/HandyG.jl.git")
```

## Provide `libhandyg`

### Option A: JLL (BinaryBuilder/Yggdrasil) (recommended)

`HandyG.jl` depends on `HandyG_jll`, which provides prebuilt `libhandyg` binaries for the supported
platforms. In most cases you do **not** need a local Fortran toolchain.

If you want to install the JLL explicitly:

```julia
using Pkg
Pkg.add("HandyG_jll")
```

### Option B: local build (developer workflow)

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

### Option C: `HANDYG_LIB` environment variable

You can point directly at a prebuilt library:

```bash
export HANDYG_LIB=/abs/path/to/libhandyg.so   # Linux
export HANDYG_LIB=/abs/path/to/libhandyg.dylib # macOS
export HANDYG_LIB=C:\\path\\to\\libhandyg.dll  # Windows
```

## Build the docs locally

```bash
julia --project=docs -e 'using Pkg; Pkg.develop(PackageSpec(path=pwd())); Pkg.instantiate(); include("docs/make.jl")'
```
