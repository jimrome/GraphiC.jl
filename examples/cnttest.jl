# ==============================================================================
# GraphiC Julia Suite: cnttest.jl
# 2D Contour Topography with Numeric Elevation Labels
#
# How to Run:
#   julia --project=julia julia/examples/cnttest.jl
#
# Output:
#   julia/examples/cnttest.svg
# ==============================================================================

using GraphiC

out_svg = joinpath(@__DIR__, "cnttest.svg")
nx, ny = 30, 30
xcoords = range(-3.0, 3.0, length=nx)
ycoords = range(-3.0, 3.0, length=ny)

zmat = zeros(Float32, nx, ny)
for j in 1:ny, i in 1:nx
    x, y = xcoords[i], ycoords[j]
    zmat[i, j] = Float32(exp(-0.3 * (x^2 + y^2)) * cos(x) * cos(y))
end

GraphiC.bgnplot(1, 'S', out_svg)
GraphiC.page(8.0, 6.0)
GraphiC.startplot(GraphiC.WHITE)
GraphiC.area2d(5.0, 4.0)
GraphiC.physor(1.5, 1.0)
GraphiC.box()
GraphiC.title("Julia 2D Contour Topography", "X Axis", "Y Axis")
GraphiC.graf("%3.1f", -3.0, 1.0, 3.0, "%3.1f", -3.0, 1.0, 3.0)
GraphiC.color(GraphiC.BLACK)
GraphiC.contour(zmat, xcoords, nx, ycoords, ny, -0.8, 0.2, 0.8, 1)

GraphiC.endplot()
GraphiC.stopplot()

println("[Julia] Generated $(out_svg) successfully")
