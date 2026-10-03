# ==============================================================================
# GraphiC Julia Suite: bartest.jl
# 2D Grouped Bar Chart with Colors and Patterns
#
# How to Run:
#   julia --project=julia julia/examples/bartest.jl
#
# Output:
#   julia/examples/bartest.svg
# ==============================================================================

using GraphiC

out_svg = joinpath(@__DIR__, "bartest.svg")

x_bars = [1.0, 2.0, 3.0, 4.0]
y_bars = [12.5, 18.2, 15.0, 22.8]
colors = [:blue, :green, :red, :black]
patterns = [1, 2, 5, 6]

GraphiC.bgnplot(1, 'S', out_svg)
GraphiC.page(8.0, 6.0)
GraphiC.startplot(GraphiC.WHITE)
GraphiC.svgcrop(0.25)
GraphiC.area2d(5.5, 4.2)
GraphiC.physor(1.5, 1.0)
GraphiC.box()

GraphiC.title("Quarterly Revenue by Division (bartest.jl)", "Quarter", "Revenue (\$ Millions)")
GraphiC.graf("%1.0f", 0.0, 1.0, 5.0, "%2.0f", 0.0, 5.0, 25.0)

# Draw bar chart with custom width, colors, and hatch patterns
GraphiC.bar(x_bars, y_bars; nxdiv=5, bwid=0.6, mode=0, colors=colors, patterns=patterns)

GraphiC.endplot()
GraphiC.stopplot()

println("[Julia] Generated $(out_svg) successfully")
