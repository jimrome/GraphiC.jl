# ==============================================================================
# GraphiC Julia Suite: polar.jl
# Polar Coordinate Grid and Spiral Curve
#
# How to Run:
#   julia --project=julia julia/examples/polar.jl
#
# Output:
#   julia/examples/polar.svg
# ==============================================================================

using GraphiC

out_svg = joinpath(@__DIR__, "polar.svg")

# Generate an Archimedean spiral: r = a * theta
n = 200
theta = range(0.0, 4π, length=n)
r = 0.5 .* theta

GraphiC.bgnplot(1, 'S', out_svg)
GraphiC.page(8.0, 6.0)
GraphiC.startplot(GraphiC.WHITE)
GraphiC.area2d(5.0, 5.0)
GraphiC.physor(1.5, 0.5)

# Draw polar coordinate grid with concentric circles and 12 radial spokes (every 30 deg)
GraphiC.polgrid(maximum(r), 0.0, 1, 4, 12, GraphiC.DRK_GRAY)

# Title & Spiral Curve
GraphiC.heading("Julia Polar Plot: Archimedean Spiral")
GraphiC.color(GraphiC.BLUE)
GraphiC.thick(1.5)
GraphiC.polcurv(r, theta, n, 0)

GraphiC.endplot()
GraphiC.stopplot()

println("[Julia] Generated $(out_svg) successfully")
