# GraphiC.jl: High-Performance Scientific Vector Graphics for Julia

**GraphiC.jl** provides direct, zero-overhead Julia bindings to the **GraphiC 2026** scientific graphics engine. Designed for research physicists, engineers, and data scientists, it generates crisp, publication-grade vector **SVG** diagrams with native companion HTML interactive viewers.

---

## Key Capabilities

* **Two Programming Paradigms**:
  * **High-Level Idiomatic API**: 1-line plotting (`GraphiC.plot`, `GraphiC.scatter`, `GraphiC.surface_plot`, `GraphiC.contour_plot`) with automatic bounds calculation, nice tick steps, and SVG auto-cropping.
  * **Procedural State-Machine API**: Full 1:1 parity with the classic C and Fortran GraphiC procedural pipelines (`bgnplot` $\to$ `page` $\to$ `area2d` $\to$ `box` $\to$ `graf` $\to$ `curve` $\to$ `endplot`).
* **Rich Notebook & IDE Display**: First-class MIME support (`image/svg+xml`) displays plots inline inside **Jupyter Notebooks**, **Pluto.jl**, and **VS Code**.
* **Zero Overhead**: Direct `ccall` FFI interface to `libgraphic.dylib` / `.so` / `.dll` without intermediate wrappers or heavy runtime overhead.
* **Extensive Scientific Visualizations**:
  * **2D Cartesian**: Multi-curve plotting, symbols, log-log, semi-log, error bars, grids, fine subdivisions.
  * **Grouped Bar Charts & Exploded Pie Charts**: Custom hatch patterns, offsets, and color palettes.
  * **Polar Coordinates**: Concentric rings, radial spokes, Archimedean and logarithmic spirals.
  * **3D Perspective Surfaces**: True hidden-line removal mesh, elevation baseline, and cutting planes.
  * **2D Contour Maps**: Elevation contour lines with numeric elevation annotations.
  * **RF / Microwave Smith Charts**: Normalized impedance/admittance coordinate grids and trajectory plotting.
  * **Continuous Perceptual Colormaps**: Built-in Viridis, Plasma, Coolwarm, and Turbo colormaps with color key gradient calibration bars.

---

## Installation

`GraphiC.jl` can be installed directly from GitHub via the Julia package manager:

```julia
using Pkg
Pkg.add(url="https://github.com/jimrome/GraphiC.jl")
```

Alternatively, from the Julia REPL interactive package mode (press `]`):

```text
pkg> add https://github.com/jimrome/GraphiC.jl
```

---

## Quickstart

### 1. High-Level Multi-Series Plotting & Legends

```julia
using GraphiC

x = range(0.0, 10.0, length=100)

# Create base figure with first curve, nice stepping, and grid
fig = GraphiC.plot(x, sin.(x);
    title="Harmonic Oscillator Waveforms",
    xlabel="Time (s)",
    ylabel="Amplitude",
    label="sin(x)",
    color=:blue,
    thick=1.5,
    xlims=(0.0, 10.0),
    ylims=(-1.2, 1.2),
    grid=true
)

# Overlay second series
GraphiC.plot!(fig, x, cos.(x);
    label="cos(x)",
    color=:red,
    ltype=:dashed
)

# Overlay discrete scatter points
GraphiC.scatter!(fig, [1.5, 3.0, 4.5, 6.0, 7.5], [0.99, -0.98, -0.21, 0.96, 0.35];
    label="Sensor Data",
    color=:magenta,
    symbol=:circle
)

# Save crisp, standalone vector SVG
GraphiC.savefig(fig, "harmonic_comparison.svg")
```

In Jupyter, Pluto, or VS Code, `fig` automatically renders the vector diagram inline.

---

### 2. Using GraphiC as a Plots.jl Backend

`GraphiC.jl` includes an official zero-overhead Julia 1.9+ package extension (`ext/GraphiCPlotsExt.jl`), enabling the standard **Plots.jl** pipeline to delegate vector rendering to GraphiC's C engine:

```julia
using Plots
import GraphiC: graphic   # or using GraphiC

# Activate GraphiC's zero-latency vector C engine
graphic()

# Idiomatic Plots.jl pipeline
x = range(0, 2π, length=100)
p = plot(x, sin.(x), label="sin(x)", color=:blue, lw=2, title="Plots.jl using GraphiC")
plot!(p, x, cos.(x), label="cos(x)", color=:red, linestyle=:dash)
scatter!(p, [1.0, 2.0, 3.0, 4.0], [0.84, 0.91, 0.14, -0.75], label="Data", color=:green)

# Generates native vector SVG with zero external dependencies
savefig(p, "plots_graphic_backend.svg")
```

---

### 3. Using GraphiC as a Makie.jl Vector Backend

`GraphiC.jl` includes an official zero-overhead Julia 1.9+ package extension (`ext/GraphiCMakieExt.jl`), bringing GraphiC's ultra-clean vector rendering and **true 3D analytic hidden-line removal** to the **Makie.jl** ecosystem:

```julia
using Makie, GraphiC
import GraphiC: graphic_makie

# Activate GraphiC as the active Makie vector rendering engine
graphic_makie()

# 1. 2D Curves & Scatter with Makie
fig = Figure()
ax = Axis(fig[1, 1], title="Harmonic Waveforms", xlabel="Time (s)", ylabel="Amplitude")
x = range(0, 2π, length=100)
lines!(ax, x, sin.(x), color=:blue, linewidth=2.0, label="Sine")
scatter!(ax, [1.0, 2.0, 3.0, 4.0], [0.84, 0.91, 0.14, -0.75], color=:red, marker=:circle, label="Data")

# Save crisp, lightweight vector SVG with zero external Cairo dependencies
save("makie_graphic_2d.svg", fig)

# 2. 3D Perspective Surface with True Analytic Hidden-Line Removal (GraphiC Professional)
fig3d = Figure()
ax3d = Axis3(fig3d[1, 1], title="3D Bessel Surface")
z = [sin(sqrt(x^2 + y^2)) for x in range(-5, 5, length=40), y in range(-5, 5, length=40)]
surface!(ax3d, z)

# Generates razor-sharp, publication-grade 3D vector SVG without rasterization artifacts
# (Requires GraphiC Professional; free Community edition supports all 2D plotting)
save("makie_graphic_3d.svg", fig3d)
```

*(Note: The free 2D Community edition bundled in the repo covers full 2D lines, multi-series curves, scatter, bar charts, and vector SVG output. 3D perspective surfaces with analytic hidden-line removal and 2D contour maps are features of **GraphiC Professional** available at [https://jamesrome.com](https://jamesrome.com)).*

---

### 4. Procedural Scientific Plotting (C / Fortran Parity)

```julia
using GraphiC

out_svg = "sample.svg"
x = range(0.0, 360.0, length=73)
y = cos.(deg2rad.(x))

GraphiC.bgnplot(1, 'S', out_svg)
GraphiC.page(8.0, 6.0)
GraphiC.startplot(GraphiC.WHITE)
GraphiC.svgcrop(0.25)
GraphiC.area2d(5.0, 3.5)
GraphiC.physor(1.5, 1.2)
GraphiC.box()

GraphiC.title("Cosine Curve Demonstration", "Angle (Degrees)", "Amplitude")
GraphiC.graf("%3.0f", 0.0, 60.0, 360.0, "%3.1f", -1.0, 0.5, 1.0)

# Draw curve and marker symbols
GraphiC.color(GraphiC.BLUE)
GraphiC.thick(1.2)
GraphiC.curve(x, y, length(x), GraphiC.SOLID)

GraphiC.color(GraphiC.RED)
GraphiC.sympick(GraphiC.SYM_CIRCLE)
for i in 1:6:length(x)
    GraphiC.symbol(x[i], y[i], GraphiC.SYM_CIRCLE)
end

GraphiC.endplot()
GraphiC.stopplot()
```

---

### 3. 3D Surface Mesh with Hidden-Line Removal

```julia
using GraphiC

nx, ny = 30, 30
z = [Float32(sin(x) * cos(y)) for x in range(-2.5, 2.5, length=nx), y in range(-2.5, 2.5, length=ny)]

p = GraphiC.surface_plot(z;
    title="3D Saddle Surface",
    xlabel="X Grid",
    ylabel="Y Grid",
    zlabel="Z Elevation",
    filename="surface.svg"
)
```

---

### 4. RF / Microwave Smith Chart

```julia
using GraphiC

GraphiC.bgnplot(1, 'S', "smith.svg")
GraphiC.page(8.0, 6.0)
GraphiC.startplot(GraphiC.WHITE)
GraphiC.area2d(5.0, 5.0)
GraphiC.physor(1.5, 0.5)

# Draw impedance circle grid
GraphiC.smdraw(GraphiC.BLACK)

# Plot normalized impedance trajectory (r, x)
GraphiC.color(GraphiC.RED)
GraphiC.thick(1.5)
for t in range(0.1, 5.0, length=50)
    GraphiC.plotrx(t, 0.5 * sin(t))
end

GraphiC.endplot()
GraphiC.stopplot()
```

---

## Examples Suite

The `examples/` folder contains verified scripts:

| Script | Output SVG | Visualization |
| :--- | :--- | :--- |
| `highlevel.jl` | `highlevel.svg` | 1-line idiomatic modern Julia plotting with auto-layout |
| `sample.jl` | `sample.svg` | Cosine curve with customized marker points |
| `d2test.jl` | `d2test.svg` | Multi-curve comparison with legends and styling |
| `d3test.jl` | `d3test.svg` | 3D wireframe perspective mesh |
| `bess3d.jl` | `bess3d.svg` | 3D Bessel $J_2(r)$ surface using `libm` `jn()` |
| `cnttest.jl` | `cnttest.svg` | 2D contour topography with numeric elevation labels |
| `smtest.jl` | `smtest.svg` | RF/microwave Smith impedance and admittance chart |
| `polar.jl` | `polar.svg` | Polar coordinate grid and Archimedean spiral |
| `bartest.jl` | `bartest.svg` | Grouped 2D bar chart with colors and hatch patterns |
| `piechart.jl` | `piechart.svg` | Exploded 2D pie chart with custom slice offsets |

To run all examples:
```bash
make run_julia_examples
```

---

## Running the Unit Test Suite

GraphiC.jl includes a test suite covering constants, colormaps, coordinate transforms, 1-line high-level plots, bar/pie/polar plots, and notebook MIME display methods:

```bash
# Run via Julia:
julia --project=julia julia/test/runtests.jl

# Or via Makefile:
make test_julia
```

All 40 unit tests pass in ~1.1 seconds.

---

## Directory Structure

```
julia/
├── Project.toml        # Julia package specification & dependencies (Libdl)
├── README.md           # This documentation
├── src/
│   └── GraphiC.jl      # Zero-overhead C-FFI bindings and high-level interface
├── test/
│   └── runtests.jl     # Complete unit test suite (40 assertions)
└── examples/           # 10 runnable demonstration scripts
    ├── highlevel.jl
    ├── sample.jl
    ├── d2test.jl
    ├── d3test.jl
    ├── bess3d.jl
    ├── cnttest.jl
    ├── smtest.jl
    ├── polar.jl
    ├── bartest.jl
    └── piechart.jl
```

---

## License & Redistribution Terms

`GraphiC.jl` and the underlying GraphiC engine are provided under the **GraphiC License Agreement** (see [LICENSE.txt](LICENSE.txt)).

* **Personal & Research Use**: You are free to use, modify, and build upon GraphiC for your personal, academic, and internal research work.
* **Commercial Redistribution Restriction**: GraphiC source code, binaries, object modules, and derivative executables may **not** be sold, bundled, or incorporated into commercial products or packages distributed or sold to third parties without an OEM redistribution license from **Scientific Endeavors Corporation**.
* For commercial OEM licensing inquiries, please visit [https://jamesrome.com](https://jamesrome.com).
