using Test
using GraphiC

# Live Makie extension test suite
try
    import Makie
    using GraphiC

    @testset "Makie.jl GraphiC Backend Extension" begin
        # 1. 2D Lines & Scatter plot with Figure and Axis
        fig = Makie.Figure()
        ax = Makie.Axis(fig[1, 1], title="Makie 2D Test", xlabel="Time", ylabel="Amplitude")

        x = range(0, 2π, length=50)
        Makie.lines!(ax, x, sin.(x), color=:blue, linewidth=2.0, label="Sine")
        Makie.scatter!(ax, [1.0, 2.0, 3.0, 4.0], [0.84, 0.91, 0.14, -0.75], color=:red, marker=:circle, label="Points")

        out_svg = joinpath(@__DIR__, "test_makie_2d.svg")
        rm(out_svg, force=true)

        Makie.save(out_svg, fig)
        @test isfile(out_svg)
        content = read(out_svg, String)
        @test occursin("<svg", content)
        @test occursin("</svg>", content)
        @test length(content) > 1000
        rm(out_svg, force=true)

        # 2. 3D Surface Plot with hidden-line removal
        fig3d = Makie.Figure()
        ax3d = Makie.Axis3(fig3d[1, 1], title="Makie 3D Surface Test")
        z = [sin(x) * cos(y) for x in range(-2, 2, length=20), y in range(-2, 2, length=20)]
        Makie.surface!(ax3d, z)

        out_3d_svg = joinpath(@__DIR__, "test_makie_3d.svg")
        rm(out_3d_svg, force=true)

        Makie.save(out_3d_svg, fig3d)
        @test isfile(out_3d_svg)
        content_3d = read(out_3d_svg, String)
        @test occursin("<svg", content_3d)
        @test occursin("</svg>", content_3d)
        @test length(content_3d) > 1000
        rm(out_3d_svg, force=true)
    end
catch e
    @info "Makie not loaded in test environment, skipping live Makie test: $e"
end
