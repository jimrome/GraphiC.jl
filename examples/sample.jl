# ==============================================================================
# GraphiC Julia Suite: sample.jl
# Multi-Waveform Analysis with Sinusoidal & Cosine Signals
#
# How to Run:
#   julia --project=julia julia/examples/sample.jl
#
# Output:
#   julia/examples/sample.svg
# ==============================================================================

using GraphiC

out_svg = joinpath(@__DIR__, "sample.svg")
n = 100
t = range(0.0, 10.0, length=n)
y1 = sin.(t)
y2 = cos.(t)

GraphiC.bgnplot(1, 'S', out_svg)
GraphiC.page(8.5, 6.5)
GraphiC.startplot(GraphiC.WHITE)
GraphiC.area2d(6.0, 4.5)
GraphiC.physor(1.5, 1.0)
GraphiC.box()
GraphiC.title("Multi-Waveform Analysis (Julia Sample)", "Phase (rad)", "Signal Amplitude")
GraphiC.graf("%3.1f", 0.0, 1.0, 10.0, "%3.1f", -1.0, 0.5, 1.0)

GraphiC.color(GraphiC.BLUE)
GraphiC.curve(t, y1, n, 0)

GraphiC.color(GraphiC.RED)
GraphiC.curve(t, y2, n, 0)

GraphiC.endplot()
GraphiC.stopplot()

println("[Julia] Generated $(out_svg) successfully")
