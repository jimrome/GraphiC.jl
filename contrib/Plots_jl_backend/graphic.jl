# GraphiC backend for Plots.jl
# https://github.com/JuliaPlots/Plots.jl
# Contributed by James A. Rome (GraphiC.jl)

const _graphic_attr = merge_with_base_supported([
    :annotations,
    :background_color_legend,
    :background_color_inside,
    :background_color_outside,
    :foreground_color_legend,
    :foreground_color_grid,
    :foreground_color_axis,
    :foreground_color_text,
    :foreground_color_border,
    :label,
    :seriescolor,
    :seriesalpha,
    :linecolor,
    :linestyle,
    :linewidth,
    :linealpha,
    :markershape,
    :markercolor,
    :markersize,
    :markeralpha,
    :markerstrokecolor,
    :markerstrokewidth,
    :markerstrokealpha,
    :fillrange,
    :fillcolor,
    :fillalpha,
    :bins,
    :layout,
    :title,
    :title_location,
    :titlefont,
    :window_title,
    :guide,
    :lims,
    :ticks,
    :scale,
    :flip,
    :rotation,
    :tickfont,
    :guidefont,
    :legend,
    :colorbar,
    :grid,
    :aspect_ratio,
    :dpi,
])

const _graphic_seriestype = [
    :path,
    :scatter,
    :straightline,
    :line,
    :contour,
    :surface,
    :wireframe,
    :shape,
]

const _graphic_style = [:auto, :solid, :dash, :dot, :dashdot, :dashdotdot]
const _graphic_marker = vcat(_allMarkers, :pixel)
const _graphic_scale = [:identity, :ln, :log2, :log10]

is_attr_supported(::GraphiCBackend, attr::Symbol) = attr in _graphic_attr
supported_attrs(::GraphiCBackend) = sort(collect(_graphic_attr))

is_seriestype_supported(::GraphiCBackend, st::Symbol) = st in _graphic_seriestype
supported_seriestypes(::GraphiCBackend) = sort(collect(_graphic_seriestype))

is_style_supported(::GraphiCBackend, s::Symbol) = s in _graphic_style
supported_styles(::GraphiCBackend) = sort(collect(_graphic_style))

is_marker_supported(::GraphiCBackend, m::Symbol) = m in _graphic_marker
is_marker_supported(::GraphiCBackend, ::Shape) = true
supported_markers(::GraphiCBackend) = sort(collect(_graphic_marker))

is_scale_supported(::GraphiCBackend, s::Symbol) = s in _graphic_scale
supported_scales(::GraphiCBackend) = sort(collect(_graphic_scale))

should_warn_on_unsupported(::GraphiCBackend) = false

_create_backend_figure(plt::Plot{GraphiCBackend}) = nothing
_before_layout_calcs(plt::Plot{GraphiCBackend}) = nothing
_update_min_padding!(sp::Subplot{GraphiCBackend}) = (sp.minpad = (0mm, 0mm, 0mm, 0mm))
_update_plot_object(plt::Plot{GraphiCBackend}) = nothing

function _show(io::IO, ::MIME"image/svg+xml", plt::Plot{GraphiCBackend})
    w_px, h_px = plt[:size]
    w_in = Float64(w_px) / 100.0
    h_in = Float64(h_px) / 100.0

    tmp = tempname() * ".svg"
    GraphiC.bgnplot(1, UInt8('S'), tmp)
    try
        GraphiC.page(w_in, h_in)
        GraphiC.startplot(GraphiC.WHITE)
        GraphiC.dashf(1)
        GraphiC.svgcrop(0.2)

        n_subplots = length(plt.subplots)
        for (idx, sp) in enumerate(plt.subplots)
            sp === nothing && continue

            if n_subplots == 1
                GraphiC.area2d(w_in * 0.75, h_in * 0.72)
                GraphiC.physor(w_in * 0.15, h_in * 0.14)
            else
                GraphiC.area2d(w_in * 0.75 / n_subplots, h_in * 0.72)
                GraphiC.physor(w_in * (0.15 + (idx - 1) * 0.8 / n_subplots), h_in * 0.14)
            end
            GraphiC.box()

            xlim = axis_limits(sp, :x)
            ylim = axis_limits(sp, :y)
            x_min, x_max = Float64(xlim[1]), Float64(xlim[2])
            y_min, y_max = Float64(ylim[1]), Float64(ylim[2])
            if x_min == x_max
                x_min -= 1.0; x_max += 1.0
            end
            if y_min == y_max
                y_min -= 1.0; y_max += 1.0
            end

            x_step = GraphiC._nice_step(x_max - x_min, 5)
            y_step = GraphiC._nice_step(y_max - y_min, 5)

            GraphiC.graf("%g", x_min, x_step, x_max, "%g", y_min, y_step, y_max)

            if get(sp[:xaxis], :grid, false) || get(sp[:yaxis], :grid, false)
                GraphiC.grid(1)
            end

            t = string(get(sp, :title, ""))
            xguide = string(get(sp[:xaxis], :guide, ""))
            yguide = string(get(sp[:yaxis], :guide, ""))
            GraphiC.title(t, xguide, yguide)

            labeled_series = []

            for series in series_list(sp)
                x = collect(Float64, series[:x])
                y = collect(Float64, series[:y])
                n = min(length(x), length(y))
                n == 0 && continue

                st = get(series.plotattributes, :seriestype, :path)
                raw_c = get(series.plotattributes, :linecolor, GraphiC.BLACK)
                clr = GraphiC.resolve_color(raw_c)
                lw = Float64(get(series.plotattributes, :linewidth, 1.0))
                ls = get(series.plotattributes, :linestyle, :solid)
                mapped_ls = GraphiC._resolve_line_style(ls)
                sym = get(series.plotattributes, :markershape, nothing)
                sym_id = sym !== nothing ? GraphiC.resolve_symbol(sym) : nothing

                lab = string(get(series.plotattributes, :label, ""))
                if !isempty(lab) && lab != "y" && lab != "y1" && lab != "y2"
                    push!(labeled_series, (lab=lab, ltype=mapped_ls, color=clr, symbol=sym_id, seriestype=st))
                end

                GraphiC.color(clr)
                GraphiC.tiline(lw)

                if st in (:path, :line, :straightline)
                    GraphiC.dashf(mapped_ls)
                    GraphiC.curve(x[1:n], y[1:n], n, 0)
                end

                if st === :scatter || sym_id !== nothing
                    actual_sym = sym_id !== nothing ? sym_id : GraphiC.SYM_CIRCLE
                    GraphiC.sympick(actual_sym)
                    for i in 1:n
                        GraphiC.symbol(x[i], y[i], actual_sym)
                    end
                end
            end

            leg_opt = get(sp, :legend, :best)
            if leg_opt != :none && !isempty(labeled_series)
                leg_x = w_in * 0.55
                leg_y = h_in * 0.76
                GraphiC.legpos(length(labeled_series), leg_x, leg_y, 1)
                for item in labeled_series
                    if item.seriestype in (:path, :line)
                        GraphiC.legend(1, item.lab, item.ltype, 0.14, item.color)
                    elseif item.symbol !== nothing
                        GraphiC.legend(0, item.lab, item.symbol, 0.14, item.color)
                    else
                        GraphiC.legend(1, item.lab, item.ltype, 0.14, item.color)
                    end
                end
            end
        end
    finally
        GraphiC.endplot()
        GraphiC.stopplot()
    end

    if isfile(tmp)
        write(io, read(tmp, String))
        rm(tmp, force=true)
    end
    nothing
end

function _display(plt::Plot{GraphiCBackend})
    tmp = tempname() * ".svg"
    open(tmp, "w") do f
        _show(f, MIME("image/svg+xml"), plt)
    end
    display(GraphiC.PlotOutput(tmp))
end
