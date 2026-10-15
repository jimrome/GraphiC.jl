"""
    GraphiCMakieExt

High-Performance Vector Graphics Backend for Makie.jl powered by GraphiC.
Implements the official Makie backend screen specification to render 2D curves,
scatter, contour plots, and 3D perspective surfaces with true analytic hidden-line
removal directly to standalone, publication-grade vector SVG.
"""
module GraphiCMakieExt

using GraphiC
import Makie

export graphic_makie, activate_makie, activate!, Screen, ScreenConfig

# Helper to unwrap Observables and RefValues
_unwrap(x) = x isa Makie.Observable ? x[] : (x isa Base.RefValue ? x[] : x)

# ==============================================================================
# Screen Specification conforming to Makie.jl
# ==============================================================================

struct ScreenConfig
    crop::Bool
    margin::Float64
    width::Float64
    height::Float64
    ScreenConfig(crop=true, margin=0.25, width=8.0, height=6.0) = new(crop, margin, width, height)
end

function Makie.merge_screen_config(::Type{ScreenConfig}, config::Dict)
    return ScreenConfig(
        Bool(get(config, :crop, true)),
        Float64(get(config, :margin, 0.25)),
        Float64(get(config, :width, 8.0)),
        Float64(get(config, :height, 6.0))
    )
end

mutable struct Screen <: Makie.MakieScreen
    scene::Union{Nothing, Makie.Scene}
    config::Any
end

Screen(scene=nothing, config=ScreenConfig(), args...) = Screen(scene, config)

Makie.backend_showable(::Type{Screen}, ::MIME"image/svg+xml") = true
Makie.backend_showable(::Type{Screen}, ::MIME"image/png") = false

"""
    activate!(; kwargs...)
    GraphiC.graphic_makie(; kwargs...)
    GraphiC.activate_makie(; kwargs...)

Activate GraphiC as the active vector rendering backend for Makie.
"""
function activate!(; kw...)
    Makie.set_active_backend!(GraphiCMakieExt)
    return nothing
end

function GraphiC.graphic_makie(; kw...)
    activate!(; kw...)
end

function GraphiC.activate_makie(; kw...)
    activate!(; kw...)
end

function __init__()
    # Set as active backend if none is set
    if ismissing(Makie.current_backend())
        activate!()
    end
end

# ==============================================================================
# Resolvers for Colors, Styles, and Markers
# ==============================================================================

function _resolve_color(c)
    val = _unwrap(c)
    if val isa Symbol
        return GraphiC.resolve_color(val)
    elseif val isa AbstractString
        return GraphiC.resolve_color(val)
    elseif val isa Integer
        return Int(val)
    elseif isdefined(Makie, :Colors) && val isa Makie.Colors.Colorant
        r = round(Int, Makie.Colors.red(val) * 255)
        g = round(Int, Makie.Colors.green(val) * 255)
        b = round(Int, Makie.Colors.blue(val) * 255)
        return GraphiC.color24(r, g, b)
    elseif val isa Tuple && length(val) >= 3
        r = round(Int, Float64(val[1]) * 255)
        g = round(Int, Float64(val[2]) * 255)
        b = round(Int, Float64(val[3]) * 255)
        return GraphiC.color24(r, g, b)
    end
    return GraphiC.BLACK
end

function _resolve_linestyle(ls)
    val = _unwrap(ls)
    return GraphiC._resolve_line_style(val)
end

function _resolve_marker(m)
    val = _unwrap(m)
    if val in (:circle, 'o', :circ)
        return GraphiC.SYM_CIRCLE
    elseif val in (:rect, :square, :box, 's')
        return GraphiC.SYM_SQUARE
    elseif val in (:diamond, 'd')
        return GraphiC.SYM_DIAMOND
    elseif val in (:utriangle, :triangle, '^')
        return GraphiC.SYM_TRIANGLE
    elseif val in (:cross, 'x')
        return GraphiC.SYM_CROSS
    elseif val in (:xcross, '+', :plus)
        return GraphiC.SYM_PLUS
    end
    return GraphiC.SYM_CIRCLE
end

function _resolve_colormap(cmap)
    val = _unwrap(cmap)
    if val in (:viridis, :Viridis)
        return GraphiC.COLORMAP_VIRIDIS
    elseif val in (:plasma, :Plasma)
        return GraphiC.COLORMAP_PLASMA
    elseif val in (:coolwarm, :Coolwarm)
        return GraphiC.COLORMAP_COOLWARM
    elseif val in (:turbo, :Turbo)
        return GraphiC.COLORMAP_TURBO
    end
    return GraphiC.COLORMAP_TURBO
end

# ==============================================================================
# Point and Data Extractors
# ==============================================================================

function _extract_2d_points(plt)
    raw = nothing
    if length(plt.args) >= 1
        raw = _unwrap(plt.args[1])
    elseif length(plt.converted) >= 1
        raw = _unwrap(plt.converted[1])
    end

    raw === nothing && return Float64[], Float64[]

    if raw isa AbstractVector
        if !isempty(raw) && (raw[1] isa Makie.Point2 || raw[1] isa Tuple || raw[1] isa AbstractVector)
            xs = [Float64(p[1]) for p in raw]
            ys = [Float64(p[2]) for p in raw]
            return xs, ys
        end
    end

    if length(plt.args) >= 2
        xs = collect(Float64, _unwrap(plt.args[1]))
        ys = collect(Float64, _unwrap(plt.args[2]))
        return xs, ys
    end

    return Float64[], Float64[]
end

function _extract_surface_data(plt)
    if length(plt.args) >= 3
        x = _unwrap(plt.args[1])
        y = _unwrap(plt.args[2])
        z = _unwrap(plt.args[3])
        return collect(Float64, x), collect(Float64, y), Matrix{Float64}(z)
    elseif length(plt.args) >= 1 && _unwrap(plt.args[1]) isa AbstractMatrix
        z = Matrix{Float64}(_unwrap(plt.args[1]))
        nr, nc = size(z)
        return collect(Float64, 1:nr), collect(Float64, 1:nc), z
    elseif length(plt.converted) >= 3
        return collect(Float64, _unwrap(plt.converted[1])), collect(Float64, _unwrap(plt.converted[2])), Matrix{Float64}(_unwrap(plt.converted[3]))
    end
    return Float64[], Float64[], Matrix{Float64}(undef, 0, 0)
end

# ==============================================================================
# Core Rendering Engine
# ==============================================================================

function render_makie_to_svg(fig_or_scene, outfile::AbstractString; width::Real=8.0, height::Real=6.0)
    actual_obj = fig_or_scene
    if hasfield(typeof(fig_or_scene), :figure)
        actual_obj = fig_or_scene.figure
    end

    GraphiC.bgnplot(1, UInt8('S'), outfile)
    try
        GraphiC.page(Float64(width), Float64(height))
        GraphiC.startplot(GraphiC.WHITE)
        GraphiC.svgcrop(0.25)

        axes = []
        if hasfield(typeof(actual_obj), :content)
            for item in actual_obj.content
                if item isa Makie.Block && (hasfield(typeof(item), :scene) || hasfield(typeof(item), :blockscene))
                    push!(axes, item)
                end
            end
        end

        if isempty(axes)
            scene = hasfield(typeof(actual_obj), :scene) ? actual_obj.scene : actual_obj
            push!(axes, scene)
        end

        n_ax = length(axes)
        for (i, ax) in enumerate(axes)
            _render_axis(ax, i, n_ax, Float64(width), Float64(height))
        end
    finally
        GraphiC.endplot()
        GraphiC.stopplot()
    end
    return outfile
end

function _render_axis(ax, idx::Int, total_axes::Int, w_in::Float64, h_in::Float64)
    is_3d = occursin("Axis3", string(typeof(ax)))

    # Viewport allocation
    if total_axes == 1
        GraphiC.area2d(w_in * 0.75, h_in * 0.72)
        GraphiC.physor(w_in * 0.15, h_in * 0.14)
    else
        cols = ceil(Int, sqrt(total_axes))
        rows = ceil(Int, total_axes / cols)
        c = (idx - 1) % cols
        r = (idx - 1) ÷ cols
        sub_w = (w_in * 0.75) / cols
        sub_h = (h_in * 0.72) / rows
        GraphiC.area2d(sub_w * 0.85, sub_h * 0.85)
        GraphiC.physor(w_in * 0.12 + c * sub_w, h_in * 0.12 + (rows - 1 - r) * sub_h)
    end

    target_scene = hasfield(typeof(ax), :scene) ? ax.scene : (hasfield(typeof(ax), :blockscene) ? ax.blockscene : ax)
    plots = target_scene.plots

    title_str = hasfield(typeof(ax), :title) ? string(_unwrap(ax.title)) : ""
    xlabel_str = hasfield(typeof(ax), :xlabel) ? string(_unwrap(ax.xlabel)) : ""
    ylabel_str = hasfield(typeof(ax), :ylabel) ? string(_unwrap(ax.ylabel)) : ""
    zlabel_str = hasfield(typeof(ax), :zlabel) ? string(_unwrap(ax.zlabel)) : ""

    # Handle 3D Surface / Wireframe plots
    surface_plots = filter(p -> occursin("Surface", string(typeof(p))) || occursin("Wireframe", string(typeof(p))), plots)
    if is_3d || !isempty(surface_plots)
        for sp in surface_plots
            x, y, z = _extract_surface_data(sp)
            if !isempty(z)
                cmap = get(sp.attributes, :colormap, :turbo)
                mapped_cmap = _resolve_colormap(cmap)
                GraphiC.heading(title_str)
                GraphiC.surface(z; title=title_str, colormap=mapped_cmap)
                return
            end
        end
    end

    # Handle 2D Plots (Lines, Scatter, Contour)
    all_x = Float64[]
    all_y = Float64[]
    extracted_series = []

    for p in plots
        p_name = string(typeof(p))
        if occursin("Lines", p_name) || occursin("LineSegments", p_name)
            xs, ys = _extract_2d_points(p)
            n = min(length(xs), length(ys))
            if n > 0
                append!(all_x, xs[1:n])
                append!(all_y, ys[1:n])
                clr = _resolve_color(get(p.attributes, :color, :blue))
                lw = Float64(_unwrap(get(p.attributes, :linewidth, 1.5)))
                ls = _resolve_linestyle(get(p.attributes, :linestyle, :solid))
                lab = string(_unwrap(get(p.attributes, :label, "")))
                push!(extracted_series, (type=:lines, x=xs[1:n], y=ys[1:n], color=clr, lw=lw, ls=ls, label=lab))
            end
        elseif occursin("Scatter", p_name)
            xs, ys = _extract_2d_points(p)
            n = min(length(xs), length(ys))
            if n > 0
                append!(all_x, xs[1:n])
                append!(all_y, ys[1:n])
                clr = _resolve_color(get(p.attributes, :color, :red))
                marker = _resolve_marker(get(p.attributes, :marker, :circle))
                lab = string(_unwrap(get(p.attributes, :label, "")))
                push!(extracted_series, (type=:scatter, x=xs[1:n], y=ys[1:n], color=clr, marker=marker, label=lab))
            end
        elseif occursin("Contour", p_name)
            x, y, z = _extract_surface_data(p)
            if !isempty(z)
                GraphiC.contour(z; title=title_str)
                return
            end
        end
    end

    if isempty(all_x) || isempty(all_y)
        GraphiC.box()
        GraphiC.title(title_str, xlabel_str, ylabel_str)
        return
    end

    x_min, x_max = minimum(all_x), maximum(all_x)
    y_min, y_max = minimum(all_y), maximum(all_y)
    if x_min == x_max
        x_min -= 1.0; x_max += 1.0
    end
    if y_min == y_max
        y_min -= 1.0; y_max += 1.0
    end

    x_step = GraphiC._nice_step(x_max - x_min, 5)
    y_step = GraphiC._nice_step(y_max - y_min, 5)

    GraphiC.box()
    GraphiC.graf("%g", x_min, x_step, x_max, "%g", y_min, y_step, y_max)

    grid_flag = false
    if hasfield(typeof(ax), :xgridvisible) && hasfield(typeof(ax), :ygridvisible)
        grid_flag = Bool(_unwrap(ax.xgridvisible)) || Bool(_unwrap(ax.ygridvisible))
    end
    if grid_flag
        GraphiC.grid(1)
    end

    GraphiC.title(title_str, xlabel_str, ylabel_str)

    # Draw series
    labeled_legends = []
    for s in extracted_series
        GraphiC.color(s.color)
        if s.type === :lines
            GraphiC.tiline(s.lw)
            GraphiC.dashf(s.ls)
            GraphiC.curve(s.x, s.y, length(s.x), 0)
            if !isempty(s.label)
                push!(labeled_legends, (label=s.label, type=1, symbol=s.ls, color=s.color))
            end
        elseif s.type === :scatter
            GraphiC.sympick(s.marker)
            for j in 1:length(s.x)
                GraphiC.symbol(s.x[j], s.y[j], s.marker)
            end
            if !isempty(s.label)
                push!(labeled_legends, (label=s.label, type=0, symbol=s.marker, color=s.color))
            end
        end
    end

    if !isempty(labeled_legends)
        leg_x = w_in * 0.55
        leg_y = h_in * 0.76
        GraphiC.legpos(length(labeled_legends), leg_x, leg_y, 1)
        for item in labeled_legends
            GraphiC.legend(item.type, item.label, item.symbol, 0.14, item.color)
        end
    end
end

# ==============================================================================
# Makie Display Hooks
# ==============================================================================

function Makie.getscreen(backend::Type{Screen}, scene::Makie.Scene, config::Dict, args...)
    return Screen(scene, config)
end

function Makie.backend_show(::Screen, io::IO, m::MIME"image/svg+xml", scene::Makie.Scene)
    tmp = tempname() * ".svg"
    try
        render_makie_to_svg(scene, tmp)
        if isfile(tmp)
            write(io, read(tmp, String))
        end
    finally
        rm(tmp, force=true)
    end
    return nothing
end

function Base.show(io::IO, m::MIME"image/svg+xml", fig::Makie.FigureLike)
    tmp = tempname() * ".svg"
    try
        render_makie_to_svg(fig, tmp)
        if isfile(tmp)
            write(io, read(tmp, String))
        end
    finally
        rm(tmp, force=true)
    end
end

function Base.display(screen::Screen, fig::Makie.FigureLike)
    tmp = tempname() * ".svg"
    render_makie_to_svg(fig, tmp)
    display(GraphiC.PlotOutput(tmp))
end

# Direct export methods on GraphiC
GraphiC.savefig(fig::Makie.FigureLike, filename::AbstractString) = render_makie_to_svg(fig, filename)

end # module
