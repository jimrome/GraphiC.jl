# ==============================================================================
# GraphiC Julia Suite: piechart.jl
# 2D Exploded Pie Chart with Custom Colors
#
# How to Run:
#   julia --project=julia julia/examples/piechart.jl
#
# Output:
#   julia/examples/piechart.svg
# ==============================================================================

using GraphiC

out_svg = joinpath(@__DIR__, "piechart.svg")

shares = [35.0, 25.0, 20.0, 15.0, 5.0]
colors = [:blue, :green, :red, :yellow, :magenta]
offsets = [0.0, 0.25, 0.0, 0.0, 0.15]  # Explode 2nd and 5th slices

GraphiC.bgnplot(1, 'S', out_svg)
GraphiC.page(8.0, 6.0)
GraphiC.startplot(GraphiC.WHITE)
GraphiC.svgcrop(0.25)
GraphiC.area2d(5.0, 5.0)
GraphiC.physor(1.5, 0.5)

GraphiC.heading("Market Share by Division (piechart.jl)")

# Draw exploded pie chart
GraphiC.pie(shares; colors=colors, offsets=offsets, size=3.5)

GraphiC.endplot()
GraphiC.stopplot()

println("[Julia] Generated $(out_svg) successfully")
