# ==============================================================================
# GraphiC Julia Suite: d2test.jl
# 2D Multi-Curve Harmonic Oscillations with Dual Colors
#
# How to Run:
#   julia --project=julia julia/examples/d2test.jl
#
# Output:
#   julia/examples/d2test.svg
# ==============================================================================

using GraphiC

out_svg = joinpath(@__DIR__, "d2test.svg")
n = 50
t = range(0.0, 10.0, length=n)
y1 = sin.(t) .* exp.(-0.1 .* t)
y2 = cos.(t) .* exp.(-0.1 .* t)

GraphiC.bgnplot(1, 'S', out_svg)
GraphiC.page(8.0, 6.0)
GraphiC.startplot(GraphiC.WHITE)
GraphiC.area2d(5.5, 4.0)
GraphiC.physor(1.5, 1.2)
GraphiC.box()
GraphiC.title("Julia Harmonic Damped Oscillations", "Time (seconds)", "Amplitude (V)")
GraphiC.graf("%3.1f", 0.0, 1.0, 10.0, "%3.1f", -1.0, 0.5, 1.0)

GraphiC.color(GraphiC.BLUE)
GraphiC.curve(t, y1, n, 0)

GraphiC.color(GraphiC.RED)
GraphiC.curve(t, y2, n, 1)

GraphiC.endplot()
GraphiC.stopplot()

println("[Julia] Generated $(out_svg) successfully")
