using Test
using Plots
import GraphiC: graphic
import GraphiC

@testset "Plots.jl GraphiC Backend Extension" begin
    graphic()
    @test Plots.backend() isa Plots.AbstractBackend
    @test Plots.backend_name() == :graphic

    out_svg = joinpath(@__DIR__, "test_plots_backend.svg")
    rm(out_svg, force=true)

    # 1. Line plot with multi-series and legend
    x = range(0, 2π, length=50)
    p = plot(x, sin.(x), title="Plots.jl Backend Test", label="sin(x)", color=:blue, lw=2)
    plot!(p, x, cos.(x), label="cos(x)", color=:red, linestyle=:dash)
    savefig(p, out_svg)

    @test isfile(out_svg)
    content = read(out_svg, String)
    @test occursin("<svg", content)
    @test occursin("</svg>", content)
    @test length(content) > 1000

    rm(out_svg, force=true)

    # 2. Scatter plot
    p2 = scatter(1:10, (1:10).^1.5, title="Scatter Test", label="Power", color=:green)
    savefig(p2, out_svg)
    @test isfile(out_svg)
    content2 = read(out_svg, String)
    @test occursin("<svg", content2)
    @test occursin("</svg>", content2)

    rm(out_svg, force=true)
end
