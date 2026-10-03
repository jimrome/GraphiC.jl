# ==============================================================================
# GraphiC Julia Suite: d3test.jl
# 3D Sinc Surface Mesh with Hidden-Line Removal
#
# How to Run:
#   julia --project=julia julia/examples/d3test.jl
#
# Output:
#   julia/examples/d3test.svg
# ==============================================================================

using GraphiC

out_svg = joinpath(@__DIR__, "d3test.svg")
nx, ny = 40, 40
x = range(-5.0, 5.0, length=nx)
y = range(-5.0, 5.0, length=ny)

zmat = zeros(Float32, nx, ny)
for j in 1:ny, i in 1:nx
    r = sqrt(x[i]^2 + y[j]^2)
    zmat[i, j] = r < 1e-5 ? 1.0f0 : Float32(sin(r) / r)
end

GraphiC.bgnplot(1, 'S', out_svg)
GraphiC.page(8.0, 6.0)
GraphiC.startplot(GraphiC.WHITE)
GraphiC.volm3d(5.0, 5.0, 3.5)
GraphiC.vuabs(10.0, -15.0, 12.0)
GraphiC.title("Julia 3D Sinc Surface Mesh", "", "")
GraphiC.graf3d(-5.0, 2.5, 5.0, -5.0, 2.5, 5.0, -0.5, 0.5, 1.0)
GraphiC.color(GraphiC.BLUE)
GraphiC.surface(zmat, nx, ny)

GraphiC.endplot()
GraphiC.stopplot()

println("[Julia] Generated $(out_svg) successfully")
