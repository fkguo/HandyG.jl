# Installation

`HandyG.jl` is a Julia wrapper around a shared library `libhandyg` built from the upstream Fortran project.

## Install the Julia package

From Julia General Registry:

```text
julia> ]
pkg> add HandyG
```

or:

```julia
using Pkg
Pkg.add("HandyG")
```

To install from the latest GitHub repository state (for development):

```julia
using Pkg
Pkg.add(url="https://github.com/fkguo/HandyG.jl.git")
```

## Runtime library: `HandyG_jll`

`HandyG.jl` depends on `HandyG_jll`, which provides prebuilt `libhandyg` binaries for the supported
platforms. End users do **not** need a local Fortran toolchain.

In most cases, installing `HandyG.jl` is sufficient. If you want to install the JLL explicitly:

```julia
using Pkg
Pkg.add("HandyG_jll")
```

## Build the docs locally

```bash
julia --project=docs -e 'using Pkg; Pkg.develop(PackageSpec(path=pwd())); Pkg.instantiate(); include("docs/make.jl")'
```
