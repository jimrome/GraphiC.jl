# GraphiC.jl Backend for Plots.jl

This directory contains the integration files and upstream submission instructions to make **GraphiC** an official first-class backend for **Plots.jl**.

---

## 1. How Users Can Use It Today (Immediate Package Extension)

`GraphiC.jl` includes a zero-overhead Julia 1.9+ package extension (`ext/GraphiCPlotsExt.jl`). 

Users simply install both packages:

```julia
using Pkg
Pkg.add("Plots")
# (or dev / add GraphiC)
```

In their Julia script or REPL:

```julia
using Plots
import GraphiC: graphic   # or using GraphiC

# Activate the zero-latency vector C engine backend
graphic()

# Standard Plots.jl syntax:
x = 0:0.1:2π
p = plot(x, sin, label="sin(x)", color=:blue, lw=2, title="GraphiC in Plots.jl")
plot!(p, x, cos, label="cos(x)", color=:red, linestyle=:dash)

# Save crisp standalone vector SVG:
savefig(p, "output.svg")
```

---

## 2. Upstream Submission to `JuliaPlots/Plots.jl`

When GraphiC is registered in the Julia General Registry, you can submit a Pull Request to [JuliaPlots/Plots.jl](https://github.com/JuliaPlots/Plots.jl):

### Step 1: Copy Backend Implementation
Copy `contrib/Plots_jl_backend/graphic.jl` into `Plots.jl/src/backends/graphic.jl`.

### Step 2: Register Backend in `Plots.jl/src/backends.jl`
Add `:graphic` to the backend list in `Plots.jl`:
```julia
# In Plots.jl/src/backends.jl:
@init_backend GraphiC

# In _backend_paths:
:graphic => @path(joinpath(@__DIR__, "backends", "graphic.jl")),
```

### Step 3: Add Dependency to `Plots.jl/Project.toml`
Add `GraphiC` under `[deps]` or `[weakdeps]`:
```toml
[deps] # or [weakdeps]
GraphiC = "e8c69134-8c88-4c3e-9bf4-e2b26090c29f"
```

Once merged, any Julia user will simply run:
```julia
using Plots
graphic()
plot(...)
```
without needing any extra imports!
