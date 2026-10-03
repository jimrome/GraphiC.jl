using Test
using GraphiC

@testset "GraphiC Julia Suite" begin

    @testset "Constants and Resolvers" begin
        @test GraphiC.BLACK == 0
        @test GraphiC.RED == 4
        @test GraphiC.WHITE == 7
        @test GraphiC.SOLID == 0
        @test GraphiC.DASHED == 2
        @test GraphiC.SYM_CIRCLE == 1

        # Resolvers
        @test GraphiC.resolve_color(:red) == GraphiC.RED
        @test GraphiC.resolve_color(:blue) == GraphiC.BLUE
        @test GraphiC.resolve_color("red") == GraphiC.RED
        @test GraphiC.resolve_color("#ff0000") == 0xff0000
        @test GraphiC.resolve_color(0x00ff00) == 0x00ff00

        @test GraphiC.resolve_ltype(:solid) == GraphiC.SOLID
        @test GraphiC.resolve_ltype(:dashed) == GraphiC.DASHED
        @test GraphiC.resolve_symbol(:circle) == GraphiC.SYM_CIRCLE
        @test GraphiC.resolve_symbol(:square) == GraphiC.SYM_SQUARE
    end

    @testset "Continuous Colormaps" begin
        c1 = GraphiC.colormap_eval(GraphiC.COLORMAP_VIRIDIS, 0.0)
        c2 = GraphiC.colormap_eval(GraphiC.COLORMAP_VIRIDIS, 1.0)
        @test c1 != c2
        @test c1 != 0 || c2 != 0
    end

    @testset "High-Level 2D Line Plot" begin
        out_svg = joinpath(@__DIR__, "test_plot.svg")
        rm(out_svg, force=true)

        x = range(0.0, 2π, length=50)
        y = sin.(x)

        p = GraphiC.plot(x, y;
            title="Julia Test Line Plot",
            xlabel="Angle (radians)",
            ylabel="sin(x)",
            color=:blue,
            ltype=:solid,
            thick=1.5,
            filename=out_svg,
            grid=true
        )

        @test p isa GraphiC.PlotOutput
        @test isfile(out_svg)
        content = read(out_svg, String)
        @test occursin("<svg", content)
        @test occursin("</svg>", content)
        rm(out_svg, force=true)
        rm(replace(out_svg, ".svg" => ".html"), force=true)
    end

    @testset "High-Level Scatter Plot" begin
        out_svg = joinpath(@__DIR__, "test_scatter.svg")
        rm(out_svg, force=true)
        rm(replace(out_svg, ".svg" => ".html"), force=true)

        x = [1.0, 2.0, 3.0, 4.0, 5.0]
        y = [2.3, 4.1, 1.8, 5.5, 3.2]

        p = GraphiC.scatter(x, y;
            title="Julia Test Scatter Plot",
            xlabel="X Data",
            ylabel="Y Data",
            color=:red,
            symbol=:circle,
            filename=out_svg
        )

        @test isfile(out_svg)
        content = read(out_svg, String)
        @test occursin("<svg", content)
        rm(out_svg, force=true)
        rm(replace(out_svg, ".svg" => ".html"), force=true)
    end

    @testset "High-Level 3D Surface Plot" begin
        out_svg = joinpath(@__DIR__, "test_surface.svg")
        rm(out_svg, force=true)
        rm(replace(out_svg, ".svg" => ".html"), force=true)

        nx, ny = 15, 15
        z = [Float32(sin(x) * cos(y)) for x in range(-2, 2, length=nx), y in range(-2, 2, length=ny)]

        p = GraphiC.surface_plot(z;
            title="Julia 3D Test Surface",
            xlabel="X", ylabel="Y", zlabel="Z",
            filename=out_svg
        )

        @test isfile(out_svg)
        content = read(out_svg, String)
        @test occursin("<svg", content)
        rm(out_svg, force=true)
        rm(replace(out_svg, ".svg" => ".html"), force=true)
    end

    @testset "High-Level 2D Contour Plot" begin
        out_svg = joinpath(@__DIR__, "test_contour.svg")
        rm(out_svg, force=true)
        rm(replace(out_svg, ".svg" => ".html"), force=true)

        nx, ny = 20, 20
        z = [Float32(exp(-0.2*(x^2 + y^2))) for x in range(-2, 2, length=nx), y in range(-2, 2, length=ny)]

        p = GraphiC.contour_plot(z;
            title="Julia Contour Test",
            xlabel="X", ylabel="Y",
            nlevels=8,
            filename=out_svg
        )

        @test isfile(out_svg)
        content = read(out_svg, String)
        @test occursin("<svg", content)
        rm(out_svg, force=true)
        rm(replace(out_svg, ".svg" => ".html"), force=true)
    end

    @testset "Procedural Coordinate Transforms" begin
        out_svg = joinpath(@__DIR__, "test_coords.svg")
        rm(out_svg, force=true)
        rm(replace(out_svg, ".svg" => ".html"), force=true)

        GraphiC.bgnplot(1, 'S', out_svg)
        GraphiC.page(8.0, 6.0)
        GraphiC.startplot(GraphiC.WHITE)
        GraphiC.area2d(5.0, 4.0)
        GraphiC.physor(1.5, 1.0)
        GraphiC.box()
        GraphiC.graf("%g", 0.0, 2.0, 10.0, "%g", 0.0, 20.0, 100.0)

        xi, yi = GraphiC.usertoinch(5.0, 50.0)
        @test xi > 1.5 && xi < 6.5
        @test yi > 1.0 && yi < 5.0

        pix = GraphiC.intopix(1.0)
        @test pix > 0
        back_in = GraphiC.pixtoin(pix)
        @test isapprox(back_in, 1.0, atol=0.01)

        xp, yp = GraphiC.usertopix(5.0, 50.0)
        @test xp > 0 && yp > 0

        GraphiC.endplot()
        GraphiC.stopplot()
        rm(out_svg, force=true)
        rm(replace(out_svg, ".svg" => ".html"), force=true)
    end

    @testset "Bar Chart" begin
        out_svg = joinpath(@__DIR__, "test_bar.svg")
        rm(out_svg, force=true)
        rm(replace(out_svg, ".svg" => ".html"), force=true)

        GraphiC.bgnplot(1, 'S', out_svg)
        GraphiC.page(8.0, 6.0)
        GraphiC.startplot(GraphiC.WHITE)
        GraphiC.area2d(5.0, 4.0)
        GraphiC.physor(1.5, 1.0)
        GraphiC.box()
        GraphiC.graf("%1.0f", 0.0, 1.0, 4.0, "%2.0f", 0.0, 5.0, 20.0)
        GraphiC.bar([1.0, 2.0, 3.0], [10.0, 15.0, 12.0]; colors=[:blue, :green, :red])
        GraphiC.endplot()
        GraphiC.stopplot()

        @test isfile(out_svg)
        @test occursin("<svg", read(out_svg, String))
        rm(out_svg, force=true)
        rm(replace(out_svg, ".svg" => ".html"), force=true)
    end

    @testset "Pie Chart" begin
        out_svg = joinpath(@__DIR__, "test_pie.svg")
        rm(out_svg, force=true)
        rm(replace(out_svg, ".svg" => ".html"), force=true)

        GraphiC.bgnplot(1, 'S', out_svg)
        GraphiC.page(8.0, 6.0)
        GraphiC.startplot(GraphiC.WHITE)
        GraphiC.pie([40.0, 35.0, 25.0]; colors=[:red, :blue, :green], offsets=[0.1, 0.0, 0.0])
        GraphiC.endplot()
        GraphiC.stopplot()

        @test isfile(out_svg)
        @test occursin("<svg", read(out_svg, String))
        rm(out_svg, force=true)
        rm(replace(out_svg, ".svg" => ".html"), force=true)
    end

    @testset "Polar Grid and Curve" begin
        out_svg = joinpath(@__DIR__, "test_polar.svg")
        rm(out_svg, force=true)
        rm(replace(out_svg, ".svg" => ".html"), force=true)

        GraphiC.bgnplot(1, 'S', out_svg)
        GraphiC.page(8.0, 6.0)
        GraphiC.startplot(GraphiC.WHITE)
        GraphiC.area2d(5.0, 5.0)
        GraphiC.physor(1.5, 0.5)
        GraphiC.polgrid(10.0, 0.0, 1, 4, 12, GraphiC.BLACK)
        th = range(0.0, 2π, length=50)
        r = range(1.0, 10.0, length=50)
        GraphiC.polcurv(r, th, 50, 0)
        GraphiC.endplot()
        GraphiC.stopplot()

        @test isfile(out_svg)
        @test occursin("<svg", read(out_svg, String))
        rm(out_svg, force=true)
        rm(replace(out_svg, ".svg" => ".html"), force=true)
    end

    @testset "Rich Display Show Methods" begin
        dummy_file = joinpath(@__DIR__, "dummy.svg")
        write(dummy_file, "<svg xmlns=\"http://www.w3.org/2000/svg\"><circle cx=\"10\" cy=\"10\" r=\"5\"/></svg>")
        po = GraphiC.PlotOutput(dummy_file)

        io = IOBuffer()
        show(io, MIME("image/svg+xml"), po)
        svg_str = String(take!(io))
        @test occursin("<circle", svg_str)

        show(io, MIME("text/plain"), po)
        plain_str = String(take!(io))
        @test occursin("GraphiC.PlotOutput", plain_str)

        rm(dummy_file, force=true)
    end

end
