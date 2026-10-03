# ==============================================================================
# GraphiC Julia Suite: bess3d.jl
# Continuous 3D Surface Shading (Bessel Membrane J2(r) cos(2 theta))
#
# How to Run:
#   julia --project=julia julia/examples/bess3d.jl
#
# Output:
#   julia/examples/bess3d.svg
# ==============================================================================

using GraphiC

out_svg = joinpath(@__DIR__, "bess3d.svg")
nx, ny = 41, 41
x = range(-1.0, 1.0, length=nx)
y = range(-1.0, 1.0, length=ny)

zmat = zeros(Float32, nx, ny)
for j in 1:ny, i in 1:nx
    xx, yy = x[i], y[j]
    r = sqrt(xx^2 + yy^2)
    if r >= 1.0
        zmat[i, j] = 0.0f0
    else
        theta = abs(xx) < 1e-20 ? Float64(pi / 2) : atan(yy, xx)
        j2 = ccall((:jn, "libm"), Cdouble, (Cint, Cdouble), 2, 5.1356 * r)
        zmat[i, j] = Float32(j2 * cos(2.0 * theta))
    end
end

GraphiC.bgnplot(1, 'S', out_svg)
GraphiC.page(9.5, 6.884)
GraphiC.startplot(GraphiC.WHITE)
GraphiC.area2d(7.4, 6.0)
GraphiC.volm3d(5.5, 5.5, 5.0)
GraphiC.vuabs(-48.0, 48.0, 15.0)
GraphiC.title("Julia Continuous 3D Surface Shading (bess3d)", "", "")
GraphiC.graf3d(-1.0, 0.5, 1.0, -1.0, 0.5, 1.0, -1.0, 0.5, 0.5)

GraphiC.color(GraphiC.BLACK)
GraphiC.surface(zmat, nx, ny)

GraphiC.endplot()
GraphiC.stopplot()

println("[Julia] Generated $(out_svg) successfully")
