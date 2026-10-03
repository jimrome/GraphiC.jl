# ==============================================================================
# GraphiC Julia Suite: smtest.jl
# RF Microwave Impedance Smith Chart
#
# How to Run:
#   julia --project=julia julia/examples/smtest.jl
#
# Output:
#   julia/examples/smtest.svg
# ==============================================================================

using GraphiC

out_svg = joinpath(@__DIR__, "smtest.svg")
npts = 50
theta = range(0.0, 2pi, length=npts)
r = 1.0 .+ 0.5 .* cos.(theta)
x = 0.5 .* sin.(theta)

GraphiC.bgnplot(1, 'S', out_svg)
GraphiC.page(8.0, 6.0)
GraphiC.startplot(GraphiC.WHITE)
GraphiC.area2d(5.0, 5.0)
GraphiC.physor(1.5, 0.5)
GraphiC.title("Julia RF Microwave Smith Chart", "", "")
GraphiC.smdraw(GraphiC.BLACK)

GraphiC.color(GraphiC.RED)
for i in 1:npts
    GraphiC.plotrx(r[i], x[i])
end

GraphiC.endplot()
GraphiC.stopplot()

println("[Julia] Generated $(out_svg) successfully")
