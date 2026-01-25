# Runtime Options and Cache

Upstream handyG exposes runtime options and a cyclic cache. `HandyG.jl` forwards a small subset needed for typical workflows.

## Clear cache

`handyG` caches intermediate results internally. The authors recommend clearing the cache between phase-space points in Monte Carlo workflows.

```julia
using HandyG

clearcache!()
```

`clearcache()` is an alias for `clearcache!()`.

## Set runtime options

```julia
using HandyG

set_options!(mpldelta=1e-15, lidelta=1e-15, hoelder_circle=1.1)
```

You can also set them individually:

```julia
set_mpldelta!(1e-15)
set_lidelta!(1e-15)
set_hoelder_circle!(1.1)
```
