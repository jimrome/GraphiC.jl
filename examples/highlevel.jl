# ==============================================================================
# GraphiC Julia Suite: highlevel.jl
# Modern 1-Line Idiomatic Scientific Plotting Interface
#
# How to Run:
#   julia --project=julia julia/examples/highlevel.jl
#
# Output:
#   julia/examples/highlevel.svg
# ==============================================================================

using GraphiC

out_svg = joinpath(@__DIR__, "highlevel.svg")

# Generate damped sine wave data
x = range(0.0, 4π, length=120)
y = exp.(-0.25 .* x) .* sin.(x)

# 1-Line publication-quality vector plot with automatic layout, scales, and crop
p = GraphiC.plot(x, y;
    title="Damped Harmonic Oscillator",
    xlabel="Time t (s)",
    ylabel="Amplitude A(t)",
    color=:blue,
    thick=1.5,
    ltype=:solid,
    symbol=:circle,
    grid=true,
    filename=out_svg
)

println("[Julia] Generated $(out_svg) successfully via 1-line high-level API")
