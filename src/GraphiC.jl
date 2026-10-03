"""
    GraphiC

High-Performance Scientific Vector Graphics Engine for Julia.
Direct, zero-overhead C FFI bindings to libgraphic with native SVG output.
"""
module GraphiC

using Libdl

export
    # Core lifecycle
    bgnplot, startplot, endplot, stopplot, get_svg_path,
    # Layout and Geometry
    page, area2d, physor, orel, metricunits, svgcrop,
    # Frame & Headings
    box, pbox, heading, label, title, xname, yname, zname, z3name,
    # Coordinates & Axes
    graf, scales, loglog, semilogx, semilogy, graf3d,
    numht, xnamht, ynamht, set_name_space,
    # Styles & Colors
    color, tcolor, bcolor, dashf, ltype, thick, tiline, sympick, symbol,
    resolve_color, resolve_ltype, resolve_symbol,
    # Drawing Primitives
    uline, linch, vector, uvector, crossat, CrossAt,
    ellipse, fillellipse, wedge,
    grid, xfgrid, yfgrid, d3grid,
    # Curves & Data
    curve, curv3d, errorbar, errorbars,
    # 3D Surfaces & Contouring
    volm3d, vuabs, survis, surmat, surface, conmat, contour,
    d3base, plane3d, waterfall_plot, waterfall_curve,
    # Engineering & Statistics
    smdraw, plotrx, polgrid, polcurv, box_plot, BoxPlot, bar, pie,
    # Typography & Text
    font, fillfont, fontfill, skew, widen,
    pltfnt, prtfnt, d3pltfnt,
    # Legends
    legpos, legend,
    # Coordinate Transforms
    usertoinch, usertopix, pixtouser, intopix, pixtoin,
    # System Integration
    svgopen, svgpush,
    # Colormaps
    colormap_eval, colorkey_gradient,
    # High-Level Idiomatic API
    plot, scatter, surface_plot, contour_plot,
    # Display Type
    PlotOutput,
    # Color Constants
    BLACK, BLUE, GREEN, CYAN, RED, MAGENTA, BROWN, WHITE,
    DRK_GRAY, LGT_BLUE, LGT_GREEN, LGT_CYAN, LGT_RED, LGT_MAGENTA,
    YELLOW, BRT_WHITE,
    # Line Styles
    SOLID, DOTTED, DASHED, LONG_DASH, CHAIN_DASH,
    # Symbol Constants
    SYM_SQUARE, SYM_CIRCLE, SYM_DEL, SYM_PLUS, SYM_CROSS,
    SYM_DIAMOND, SYM_TRIANGLE, SYM_STICK_FIGURE, SYM_FEET_PLUS,
    SYM_HLINE, SYM_VLINE, SYM_BOX, SYM_DOT, SYM_BIG_DOT, SYM_BIGGER_DOT,
    # Colormap Constants
    COLORMAP_VIRIDIS, COLORMAP_PLASMA, COLORMAP_COOLWARM, COLORMAP_TURBO

# ==============================================================================
# Color Constants
# ==============================================================================
const BLACK       = 0
const BLUE        = 1
const GREEN       = 2
const CYAN        = 3
const RED         = 4
const MAGENTA     = 5
const BROWN       = 6
const WHITE       = 7
const DRK_GRAY    = 8
const LGT_BLUE    = 9
const LGT_GREEN   = 10
const LGT_CYAN    = 11
const LGT_RED     = 12
const LGT_MAGENTA = 13
const YELLOW      = 14
const BRT_WHITE   = 15

# Line Styles
const SOLID       = 0
const DOTTED      = 1
const DASHED      = 2
const LONG_DASH   = 3
const CHAIN_DASH  = 4

# Symbols
const SYM_SQUARE        = 0
const SYM_CIRCLE        = 1
const SYM_DEL           = 2
const SYM_PLUS          = 3
const SYM_CROSS         = 4
const SYM_DIAMOND       = 5
const SYM_TRIANGLE      = 6
const SYM_STICK_FIGURE  = 7
const SYM_FEET_PLUS     = 8
const SYM_HLINE         = 9
const SYM_VLINE         = 10
const SYM_BOX           = 11
const SYM_DOT           = 12
const SYM_BIG_DOT       = 13
const SYM_BIGGER_DOT    = 14

# Colormaps
const COLORMAP_VIRIDIS  = 0
const COLORMAP_PLASMA   = 1
const COLORMAP_COOLWARM = 2
const COLORMAP_TURBO    = 3

# ==============================================================================
# Resolvers for Symbols & Names
# ==============================================================================
const COLOR_DICT = Dict{Symbol, Int}(
    :black         => BLACK,
    :blue          => BLUE,
    :green         => GREEN,
    :cyan          => CYAN,
    :red           => RED,
    :magenta       => MAGENTA,
    :brown         => BROWN,
    :white         => WHITE,
    :drk_gray      => DRK_GRAY,
    :darkgray      => DRK_GRAY,
    :dark_gray     => DRK_GRAY,
    :gray          => DRK_GRAY,
    :lgt_blue      => LGT_BLUE,
    :lightblue     => LGT_BLUE,
    :light_blue    => LGT_BLUE,
    :lgt_green     => LGT_GREEN,
    :lightgreen    => LGT_GREEN,
    :light_green   => LGT_GREEN,
    :lgt_cyan      => LGT_CYAN,
    :lightcyan     => LGT_CYAN,
    :light_cyan    => LGT_CYAN,
    :lgt_red       => LGT_RED,
    :lightred      => LGT_RED,
    :light_red     => LGT_RED,
    :lgt_magenta   => LGT_MAGENTA,
    :lightmagenta  => LGT_MAGENTA,
    :yellow        => YELLOW,
    :brt_white     => BRT_WHITE,
    :bright_white  => BRT_WHITE
)

function resolve_color(c)
    if c isa Integer
        return Int(c)
    elseif c isa Symbol
        return get(COLOR_DICT, c, BLACK)
    elseif c isa AbstractString
        sc = Symbol(lowercase(strip(c)))
        if haskey(COLOR_DICT, sc)
            return COLOR_DICT[sc]
        elseif startswith(c, "#")
            return parse(Int, c[2:end], base=16)
        elseif startswith(c, "0x") || startswith(c, "0X")
            return parse(Int, c[3:end], base=16)
        end
    end
    return BLACK
end

const LTYPE_DICT = Dict{Symbol, Int}(
    :solid       => SOLID,
    :dotted      => DOTTED,
    :dashed      => DASHED,
    :long_dash   => LONG_DASH,
    :chain_dash  => CHAIN_DASH
)

function resolve_ltype(s)
    if s isa Integer
        return Int(s)
    elseif s isa Symbol
        return get(LTYPE_DICT, s, SOLID)
    end
    return SOLID
end

const SYM_DICT = Dict{Symbol, Int}(
    :square        => SYM_SQUARE,
    :circle        => SYM_CIRCLE,
    :del           => SYM_DEL,
    :plus          => SYM_PLUS,
    :cross         => SYM_CROSS,
    :diamond       => SYM_DIAMOND,
    :triangle      => SYM_TRIANGLE,
    :stick_figure  => SYM_STICK_FIGURE,
    :feet_plus     => SYM_FEET_PLUS,
    :hline         => SYM_HLINE,
    :vline         => SYM_VLINE,
    :box           => SYM_BOX,
    :dot           => SYM_DOT,
    :big_dot       => SYM_BIG_DOT,
    :bigger_dot    => SYM_BIGGER_DOT
)

function resolve_symbol(s)
    if s isa Integer
        return Int(s)
    elseif s isa Symbol
        return get(SYM_DICT, s, SYM_CIRCLE)
    end
    return SYM_CIRCLE
end

# ==============================================================================
# Dynamic Library Loader
# ==============================================================================
const LIB_HANDLE = Ref{Ptr{Cvoid}}(C_NULL)

function _find_library()
    if haskey(ENV, "GRAPHIC_LIB_PATH") && isfile(ENV["GRAPHIC_LIB_PATH"])
        return ENV["GRAPHIC_LIB_PATH"]
    end

    lib_names = if Sys.isapple()
        ["libgraphic.dylib", "libgraphic.so"]
    elseif Sys.iswindows()
        ["graphic.dll", "libgraphic.dll"]
    else
        ["libgraphic.so", "libgraphic.dylib"]
    end

    pkg_dir = dirname(dirname(@__FILE__))
    search_dirs = [
        joinpath(pkg_dir, "lib"),
        joinpath(pkg_dir, "..", "lib"),
        joinpath(pkg_dir, "..", "build"),
        "/usr/local/lib",
        "/opt/homebrew/lib"
    ]

    for d in search_dirs
        for name in lib_names
            cand = normpath(joinpath(d, name))
            if isfile(cand)
                return cand
            end
        end
    end

    return Sys.isapple() ? "libgraphic.dylib" : (Sys.iswindows() ? "graphic.dll" : "libgraphic.so")
end

function _get_handle()
    if LIB_HANDLE[] == C_NULL
        path = _find_library()
        handle = Libdl.dlopen(path)
        if handle == C_NULL
            error("Could not load GraphiC dynamic library from: $path")
        end
        LIB_HANDLE[] = handle
    end
    return LIB_HANDLE[]
end

function __init__()
    if !haskey(ENV, "GPC_NONINTERACTIVE")
        ENV["GPC_NONINTERACTIVE"] = "1"
    end
    try
        _get_handle()
    catch
    end
end

# ==============================================================================
# Rich Display Wrapper for Notebooks & VS Code
# ==============================================================================
struct PlotOutput
    path::String
end

function Base.show(io::IO, ::MIME"image/svg+xml", p::PlotOutput)
    if isfile(p.path)
        write(io, read(p.path, String))
    else
        write(io, "<svg xmlns=\"http://www.w3.org/2000/svg\"><text x=\"10\" y=\"20\">File not found: $(p.path)</text></svg>")
    end
end

function Base.show(io::IO, ::MIME"text/plain", p::PlotOutput)
    println(io, "GraphiC.PlotOutput(\"$(p.path)\")")
end

const CURRENT_OUTPUT = Ref{String}("")

# ==============================================================================
# Core API Bindings
# ==============================================================================

"""
    bgnplot(device, mode, filename)

Initialize the GraphiC plotting session.
- `device`: Device ID (typically 1 for vector output)
- `mode`: Driver character ('S' for SVG, 'g' for screen/TKF)
- `filename`: Target vector SVG output filename
"""
function bgnplot(device::Integer, mode::Union{Char, Integer}, filename::AbstractString)
    m = mode isa Char ? Int(UInt8(mode)) : Int(mode)
    CURRENT_OUTPUT[] = String(filename)
    fn_ptr = Libdl.dlsym(_get_handle(), :bgnplot)
    ccall(fn_ptr, Cvoid, (Cint, Cint, Cstring), Cint(device), Cint(m), String(filename))
end

"""Get the actual rendered SVG path from the C SVG driver."""
function get_svg_path()
    fn_ptr = Libdl.dlsym(_get_handle(), :gpc_get_svg_path)
    cstr = ccall(fn_ptr, Cstring, ())
    return cstr == C_NULL ? CURRENT_OUTPUT[] : unsafe_string(cstr)
end

"""Start a new plot page with background color."""
function startplot(bgcolor::Integer=WHITE)
    fn_ptr = Libdl.dlsym(_get_handle(), :startplot)
    ccall(fn_ptr, Cvoid, (Cint,), Cint(bgcolor))
end

"""Conclude the current plot. Returns a `PlotOutput` object for rich display."""
function endplot()
    fn_ptr = Libdl.dlsym(_get_handle(), :endplot)
    ccall(fn_ptr, Cint, ())
    path = get_svg_path()
    if !isempty(path)
        CURRENT_OUTPUT[] = path
    end
    return PlotOutput(CURRENT_OUTPUT[])
end

"""Terminate the GraphiC session, closing all file drivers."""
function stopplot()
    fn_ptr = Libdl.dlsym(_get_handle(), :stopplot)
    ccall(fn_ptr, Cvoid, ())
end

# Layout & Dimensions
"""Set page dimensions in inches."""
function page(width::Real, height::Real)
    fn_ptr = Libdl.dlsym(_get_handle(), :page)
    ccall(fn_ptr, Cvoid, (Cfloat, Cfloat), Cfloat(width), Cfloat(height))
end

"""Set 2D plotting viewport dimensions in inches."""
function area2d(width::Real, height::Real)
    fn_ptr = Libdl.dlsym(_get_handle(), :area2d)
    ccall(fn_ptr, Cvoid, (Cfloat, Cfloat), Cfloat(width), Cfloat(height))
end

"""Set absolute physical origin of the plot area in inches."""
function physor(x::Real, y::Real)
    fn_ptr = Libdl.dlsym(_get_handle(), :physor)
    ccall(fn_ptr, Cvoid, (Cfloat, Cfloat), Cfloat(x), Cfloat(y))
end

"""Set origin offset relative to current position."""
function orel(x::Real, y::Real)
    fn_ptr = Libdl.dlsym(_get_handle(), :orel)
    ccall(fn_ptr, Cvoid, (Cfloat, Cfloat), Cfloat(x), Cfloat(y))
end

"""Set units: 0 = inches, 1 = millimeters."""
function metricunits(flag::Integer)
    fn_ptr = Libdl.dlsym(_get_handle(), :metricunits)
    ccall(fn_ptr, Cvoid, (Cint,), Cint(flag))
end

"""Crop SVG canvas tightly to bounding box with optional padding margin in inches."""
function svgcrop(margin::Real=0.25)
    fn_ptr = Libdl.dlsym(_get_handle(), :svgcrop)
    ccall(fn_ptr, Cvoid, (Cfloat,), Cfloat(margin))
end

# Frame & Annotations
"""Draw a boundary box around the current plotting area."""
function box()
    fn_ptr = Libdl.dlsym(_get_handle(), :box)
    ccall(fn_ptr, Cvoid, ())
end

"""Draw a tick-marked boundary box."""
function pbox()
    fn_ptr = Libdl.dlsym(_get_handle(), :pbox)
    ccall(fn_ptr, Cvoid, ())
end

"""Draw main plot heading / title."""
function heading(title_str::AbstractString)
    fn_ptr = Libdl.dlsym(_get_handle(), :heading)
    ccall(fn_ptr, Cvoid, (Cstring,), String(title_str))
end

"""Label the X and Y axes."""
function label(xlab::AbstractString, ylab::AbstractString)
    if !isempty(xlab)
        xname(xlab)
    end
    if !isempty(ylab)
        yname(ylab)
    end
end

"""Convenience helper to set Title, X-axis label, and Y-axis label in one call."""
function title(head_str::AbstractString, xlab::AbstractString="", ylab::AbstractString="")
    if !isempty(head_str)
        heading(head_str)
    end
    if !isempty(xlab)
        xname(xlab)
    end
    if !isempty(ylab)
        yname(ylab)
    end
end

function xname(name_str::AbstractString)
    fn_ptr = Libdl.dlsym(_get_handle(), :xname)
    ccall(fn_ptr, Cvoid, (Cstring,), String(name_str))
end

function yname(name_str::AbstractString)
    fn_ptr = Libdl.dlsym(_get_handle(), :yname)
    ccall(fn_ptr, Cvoid, (Cstring,), String(name_str))
end

function z3name(name_str::AbstractString)
    fn_ptr = Libdl.dlsym(_get_handle(), :z3name)
    ccall(fn_ptr, Cvoid, (Cstring,), String(name_str))
end
const zname = z3name

# Font Sizing & Spacing
"""Set axis numeral height in inches."""
function numht(height::Real)
    fn_ptr = Libdl.dlsym(_get_handle(), :numht)
    ccall(fn_ptr, Cvoid, (Cfloat,), Cfloat(height))
end

"""Set X-axis label height in inches."""
function xnamht(height::Real)
    fn_ptr = Libdl.dlsym(_get_handle(), :xnamht)
    ccall(fn_ptr, Cvoid, (Cfloat,), Cfloat(height))
end

"""Set Y-axis label height in inches."""
function ynamht(height::Real)
    fn_ptr = Libdl.dlsym(_get_handle(), :ynamht)
    ccall(fn_ptr, Cvoid, (Cfloat,), Cfloat(height))
end

"""Set spacing between axis tick numbers and axis label."""
function set_name_space(axis::Integer, factor::Real)
    fn_ptr = Libdl.dlsym(_get_handle(), :SetNameSpace)
    ccall(fn_ptr, Cvoid, (Cint, Cfloat), Cint(axis), Cfloat(factor))
end

# Colors & Styles
"""Set current foreground drawing color (0-15, 24-bit TrueColor hex 0xRRGGBB, or symbol :red, :blue, etc.)."""
function color(c)
    clr = resolve_color(c)
    fn_ptr = Libdl.dlsym(_get_handle(), :color)
    ccall(fn_ptr, Cvoid, (Cint,), Cint(clr))
end

"""Set text font color."""
function tcolor(c)
    clr = resolve_color(c)
    fn_ptr = Libdl.dlsym(_get_handle(), :tcolor)
    ccall(fn_ptr, Cvoid, (Cint,), Cint(clr))
end

"""Set background / fill color."""
function bcolor(c)
    clr = resolve_color(c)
    fn_ptr = Libdl.dlsym(_get_handle(), :bcolor)
    ccall(fn_ptr, Cvoid, (Cint,), Cint(clr))
end

"""Set line dash pattern scale factor."""
function dashf(factor::Real)
    fn_ptr = Libdl.dlsym(_get_handle(), :dashf)
    ccall(fn_ptr, Cvoid, (Cfloat,), Cfloat(factor))
end

"""Set line style (SOLID=0, DOTTED=1, DASHED=2, LONG_DASH=3, CHAIN_DASH=4, or :solid, :dashed, etc.)."""
function ltype(t)
    dashf(Float32(resolve_ltype(t)))
end

"""Set line width / stroke thickness in inches."""
function tiline(thickness::Real)
    fn_ptr = Libdl.dlsym(_get_handle(), :tiline)
    ccall(fn_ptr, Cvoid, (Cfloat,), Cfloat(thickness))
end
const thick = tiline

"""Select point marker symbol ID."""
function sympick(sym_num)
    fn_ptr = Libdl.dlsym(_get_handle(), :sympick)
    ccall(fn_ptr, Cvoid, (Cint,), Cint(resolve_symbol(sym_num)))
end

"""Draw a marker symbol at coordinates (x, y)."""
function symbol(x::Real, y::Real, sym_num)
    fn_ptr = Libdl.dlsym(_get_handle(), :symbol)
    ccall(fn_ptr, Cvoid, (Cfloat, Cfloat, Cint), Cfloat(x), Cfloat(y), Cint(resolve_symbol(sym_num)))
end

# Coordinate Axes
"""Define linear 2D plot axes with formatting, ranges, and tick intervals."""
function graf(fmtx::AbstractString, x1::Real, xstep::Real, x2::Real,
              fmty::AbstractString, y1::Real, ystep::Real, y2::Real)
    fn_ptr = Libdl.dlsym(_get_handle(), :graf)
    ccall(fn_ptr, Cvoid, (Cstring, Cfloat, Cfloat, Cfloat, Cstring, Cfloat, Cfloat, Cfloat),
          String(fmtx), Cfloat(x1), Cfloat(xstep), Cfloat(x2),
          String(fmty), Cfloat(y1), Cfloat(ystep), Cfloat(y2))
end

"""Set plot scaling without drawing axes."""
function scales(x1::Real, x2::Real, y1::Real, y2::Real)
    fn_ptr = Libdl.dlsym(_get_handle(), :scales)
    ccall(fn_ptr, Cvoid, (Cfloat, Cfloat, Cfloat, Cfloat), Cfloat(x1), Cfloat(x2), Cfloat(y1), Cfloat(y2))
end

"""Configure log-log axes."""
function loglog(x1::Real, x2::Real, y1::Real, y2::Real)
    fn_ptr = Libdl.dlsym(_get_handle(), :loglog)
    ccall(fn_ptr, Cvoid, (Cfloat, Cfloat, Cfloat, Cfloat), Cfloat(x1), Cfloat(x2), Cfloat(y1), Cfloat(y2))
end

"""Configure semi-log X axes."""
function semilogx(x1::Real, x2::Real, y1::Real, y2::Real)
    fn_ptr = Libdl.dlsym(_get_handle(), :semilogx)
    ccall(fn_ptr, Cvoid, (Cfloat, Cfloat, Cfloat, Cfloat), Cfloat(x1), Cfloat(x2), Cfloat(y1), Cfloat(y2))
end

"""Configure semi-log Y axes."""
function semilogy(x1::Real, x2::Real, y1::Real, y2::Real)
    fn_ptr = Libdl.dlsym(_get_handle(), :semilogy)
    ccall(fn_ptr, Cvoid, (Cfloat, Cfloat, Cfloat, Cfloat), Cfloat(x1), Cfloat(x2), Cfloat(y1), Cfloat(y2))
end

# Drawing Primitives
"""Draw a line segment between points in user/data coordinates."""
function uline(x1::Real, y1::Real, x2::Real, y2::Real, newcurv::Integer=1)
    fn_ptr = Libdl.dlsym(_get_handle(), :uline)
    ccall(fn_ptr, Cvoid, (Cfloat, Cfloat, Cfloat, Cfloat, Cint),
          Cfloat(x1), Cfloat(y1), Cfloat(x2), Cfloat(y2), Cint(newcurv))
end

"""Draw a line segment between points in physical page inches."""
function linch(x1::Real, y1::Real, x2::Real, y2::Real, newcurv::Integer=1)
    fn_ptr = Libdl.dlsym(_get_handle(), :linch)
    ccall(fn_ptr, Cvoid, (Cfloat, Cfloat, Cfloat, Cfloat, UInt8),
          Cfloat(x1), Cfloat(y1), Cfloat(x2), Cfloat(y2), UInt8(newcurv))
end

"""Draw a directional arrow vector in user coordinates."""
function uvector(xfrom::Real, yfrom::Real, xto::Real, yto::Real, ltow::Real=1.0, size::Real=0.1, type::AbstractString="A")
    fn_ptr = Libdl.dlsym(_get_handle(), :uvector)
    ccall(fn_ptr, Cvoid, (Cfloat, Cfloat, Cfloat, Cfloat, Cfloat, Cfloat, Cstring),
          Cfloat(xfrom), Cfloat(yfrom), Cfloat(xto), Cfloat(yto), Cfloat(ltow), Cfloat(size), String(type))
end

"""Draw a directional arrow vector in physical page inches."""
function vector(xfrom::Real, yfrom::Real, xto::Real, yto::Real, ltow::Real=1.0, size::Real=0.1, type::AbstractString="A")
    fn_ptr = Libdl.dlsym(_get_handle(), :vector)
    ccall(fn_ptr, Cvoid, (Cfloat, Cfloat, Cfloat, Cfloat, Cfloat, Cfloat, Cstring),
          Cfloat(xfrom), Cfloat(yfrom), Cfloat(xto), Cfloat(yto), Cfloat(ltow), Cfloat(size), String(type))
end

"""Draw intersecting crosshairs at coordinates (x, y)."""
function crossat(x::Real, y::Real)
    fn_ptr = Libdl.dlsym(_get_handle(), :CrossAt)
    ccall(fn_ptr, Cvoid, (Cfloat, Cfloat), Cfloat(x), Cfloat(y))
end
const CrossAt = crossat

"""Draw an ellipse or elliptical arc."""
function ellipse(xc::Real, yc::Real, xr::Real, yr::Real, rotation::Real=0.0, th1::Real=0.0, th2::Real=360.0, degrees::Bool=true, units::Integer=0)
    fn_ptr = Libdl.dlsym(_get_handle(), :ellipse)
    ccall(fn_ptr, Cvoid, (Cfloat, Cfloat, Cfloat, Cfloat, Cfloat, Cfloat, Cfloat, UInt8, Cint),
          Cfloat(xc), Cfloat(yc), Cfloat(xr), Cfloat(yr), Cfloat(rotation), Cfloat(th1), Cfloat(th2),
          UInt8(degrees ? 1 : 0), Cint(units))
end

"""Toggle ellipse interior filling."""
function fillellipse(onoff::Integer=1, pattern::Integer=0, border::Integer=0)
    fn_ptr = Libdl.dlsym(_get_handle(), :fillellipse)
    ccall(fn_ptr, Cvoid, (Cint, Cint, Cint), Cint(onoff), Cint(pattern), Cint(border))
end

"""Draw an annular polar wedge."""
function wedge(rmin::Real, rmax::Real, thmin::Real, thmax::Real, pattern::Integer=0, border::Integer=0)
    fn_ptr = Libdl.dlsym(_get_handle(), :wedge)
    ccall(fn_ptr, Cvoid, (Cfloat, Cfloat, Cfloat, Cfloat, Cint, Cint),
          Cfloat(rmin), Cfloat(rmax), Cfloat(thmin), Cfloat(thmax), Cint(pattern), Cint(border))
end

"""Toggle Cartesian coordinate grid lines."""
function grid(gridon::Integer=1)
    fn_ptr = Libdl.dlsym(_get_handle(), :grid)
    ccall(fn_ptr, Cvoid, (Cint,), Cint(gridon))
end

"""Draw fine vertical X grid subdivisions."""
function xfgrid(fon::Integer=1, nx::Integer=5)
    fn_ptr = Libdl.dlsym(_get_handle(), :xfgrid)
    ccall(fn_ptr, Cvoid, (Cint, Cint), Cint(fon), Cint(nx))
end

"""Draw fine horizontal Y grid subdivisions."""
function yfgrid(fon::Integer=1, ny::Integer=5)
    fn_ptr = Libdl.dlsym(_get_handle(), :yfgrid)
    ccall(fn_ptr, Cvoid, (Cint, Cint), Cint(fon), Cint(ny))
end

"""Draw 3D perspective grid lines."""
function d3grid(subdiv::Integer=5, label::Integer=0)
    fn_ptr = Libdl.dlsym(_get_handle(), :d3grid)
    ccall(fn_ptr, Cvoid, (Cint, Cint), Cint(subdiv), Cint(label))
end

# Curves
"""
    curve(x, y, n, ltype=0)

Plot a 2D curve through `(x, y)` coordinate vectors.
- `n`: Number of points
- `ltype`: Line type (0 = Solid, 1 = Dotted, 2 = Dashed, <0 = Symbols only)
"""
function curve(x::AbstractVector{<:Real}, y::AbstractVector{<:Real}, n::Integer=min(length(x), length(y)), ltype::Integer=0)
    fx = Float32.(x[1:n])
    fy = Float32.(y[1:n])
    fn_ptr = Libdl.dlsym(_get_handle(), :curve)
    ccall(fn_ptr, Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}, Cint, Cint), fx, fy, Cint(n), Cint(ltype))
end

"""Plot a 3D curve through `(x, y, z)` coordinate vectors."""
function curv3d(x::AbstractVector{<:Real}, y::AbstractVector{<:Real}, z::AbstractVector{<:Real}, n::Integer=min(length(x), length(y), length(z)), ltype::Integer=0)
    fx = Float32.(x[1:n])
    fy = Float32.(y[1:n])
    fz = Float32.(z[1:n])
    fn_ptr = Libdl.dlsym(_get_handle(), :curv3d)
    ccall(fn_ptr, Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}, Ptr{Cfloat}, Cint, Cint), fx, fy, fz, Cint(n), Cint(ltype))
end

"""Plot error bars at single point (x, y)."""
function errorbar(x::Real, xmin::Real, xmax::Real, y::Real, ymin::Real, ymax::Real)
    fn_ptr = Libdl.dlsym(_get_handle(), :errorbar)
    ccall(fn_ptr, Cvoid, (Cfloat, Cfloat, Cfloat, Cfloat, Cfloat, Cfloat),
          Cfloat(x), Cfloat(xmin), Cfloat(xmax), Cfloat(y), Cfloat(ymin), Cfloat(ymax))
end

"""Plot symmetric vertical error bars across vectors."""
function errorbars(x::AbstractVector{<:Real}, y::AbstractVector{<:Real}, yerr::AbstractVector{<:Real})
    n = min(length(x), length(y), length(yerr))
    for i in 1:n
        xi = Float32(x[i])
        yi = Float32(y[i])
        ei = Float32(yerr[i])
        errorbar(xi, xi, xi, yi, yi - ei, yi + ei)
    end
end

# 3D Volumes & Surfaces
"""Set 3D workbox dimensions in inches."""
function volm3d(x::Real, y::Real, z::Real)
    fn_ptr = Libdl.dlsym(_get_handle(), :volm3d)
    ccall(fn_ptr, Cvoid, (Cfloat, Cfloat, Cfloat), Cfloat(x), Cfloat(y), Cfloat(z))
end

"""Set 3D absolute viewpoint coordinates."""
function vuabs(x::Real, y::Real, z::Real)
    fn_ptr = Libdl.dlsym(_get_handle(), :vuabs)
    ccall(fn_ptr, Cvoid, (Cfloat, Cfloat, Cfloat), Cfloat(x), Cfloat(y), Cfloat(z))
end

"""Draw 3D coordinate frame box and axes."""
function graf3d(x1::Real, xstep::Real, x2::Real,
                y1::Real, ystep::Real, y2::Real,
                z1::Real, zstep::Real, z2::Real)
    fn_ptr = Libdl.dlsym(_get_handle(), :graf3d)
    ccall(fn_ptr, Cvoid, (Cfloat, Cfloat, Cfloat, Cfloat, Cfloat, Cfloat, Cfloat, Cfloat, Cfloat),
          Cfloat(x1), Cfloat(xstep), Cfloat(x2),
          Cfloat(y1), Cfloat(ystep), Cfloat(y2),
          Cfloat(z1), Cfloat(zstep), Cfloat(z2))
end

"""Set surface mesh visibility mode ("top", "bottom", "both")."""
function survis(vis::AbstractString="top")
    fn_ptr = Libdl.dlsym(_get_handle(), :survis)
    ccall(fn_ptr, Cvoid, (Cstring,), String(vis))
end

"""Configure baseline elevation plane for 3D surfaces."""
function d3base(isbase::Integer=1, color::Integer=0)
    fn_ptr = Libdl.dlsym(_get_handle(), :d3base)
    ccall(fn_ptr, Cvoid, (Cint, Cint), Cint(isbase), Cint(color))
end

"""Draw a cutting plane in 3D perspective space."""
function plane3d(wplane::Union{Char, Integer}='Z', pos::Real=0.0, hide::Union{Char, Integer}='1')
    c_wp = wplane isa Char ? UInt8(wplane) : UInt8(wplane)
    c_h = hide isa Char ? UInt8(hide) : UInt8(hide)
    fn_ptr = Libdl.dlsym(_get_handle(), :plane3d)
    ccall(fn_ptr, Cvoid, (UInt8, Cfloat, UInt8), c_wp, Cfloat(pos), c_h)
end

"""
    surmat(zmat, nx, ny)

Plot a 3D surface mesh with hidden line removal from a matrix of heights.
"""
function surmat(zmat::AbstractMatrix{<:Real}, nx::Integer=size(zmat, 1), ny::Integer=size(zmat, 2))
    flat = Float32.(vec(zmat[1:nx, 1:ny]))
    fn_ptr = Libdl.dlsym(_get_handle(), :surmat)
    ccall(fn_ptr, Cvoid, (Ptr{Cfloat}, Cint, Cint), flat, Cint(nx), Cint(ny))
end

"""High-level surface plotting helper with automatic top-visibility."""
function surface(zmat::AbstractMatrix{<:Real}, nx::Integer=size(zmat, 1), ny::Integer=size(zmat, 2))
    survis("top")
    surmat(zmat, nx, ny)
end

# Waterfall Plots
"""Draw a single 2D spectral curve in 3D perspective space with hidden line removal."""
function waterfall_curve(x::AbstractVector{<:Real}, y::Real, z::AbstractVector{<:Real})
    fx = Float32.(x)
    fz = Float32.(z)
    npts = min(length(fx), length(fz))
    fn_ptr = Libdl.dlsym(_get_handle(), :WaterfallCurve)
    ccall(fn_ptr, Cvoid, (Ptr{Cfloat}, Cfloat, Ptr{Cfloat}, Cint), fx, Cfloat(y), fz, Cint(npts))
end

# Contouring
"""
    conmat(zmat, x, nx, y, ny, orig, step, maxq, labint=1)

Draw a 2D contour plot over grid points `x` and `y`.
"""
function conmat(zmat::AbstractMatrix{<:Real}, x::AbstractVector{<:Real}, nx::Integer,
                y::AbstractVector{<:Real}, ny::Integer,
                orig::Real, step::Real, maxq::Real, labint::Integer=1)
    flat = Float32.(vec(zmat[1:nx, 1:ny]))
    fx = Float32.(x[1:nx])
    fy = Float32.(y[1:ny])
    fn_ptr = Libdl.dlsym(_get_handle(), :conmat)
    ccall(fn_ptr, Cvoid,
          (Ptr{Cfloat}, Ptr{Cfloat}, Cint, Ptr{Cfloat}, Cint, Cfloat, Cfloat, Cfloat, Ptr{Cvoid}, Cint),
          flat, fx, Cint(nx), fy, Cint(ny), Cfloat(orig), Cfloat(step), Cfloat(maxq), C_NULL, Cint(labint))
end

const contour = conmat

# Engineering Specializations
"""Draw an RF microwave Smith chart impedance circle grid."""
function smdraw(grid_color::Integer=BLACK)
    fn_ptr = Libdl.dlsym(_get_handle(), :smdraw)
    ccall(fn_ptr, Cvoid, (Cint,), Cint(grid_color))
end

"""Plot a normalized impedance coordinate point `(r, x)` on the active Smith chart."""
function plotrx(r::Real, x::Real)
    fn_ptr = Libdl.dlsym(_get_handle(), :plotrx)
    ccall(fn_ptr, Cvoid, (Cfloat, Cfloat), Cfloat(r), Cfloat(x))
end

"""
    polgrid(rmax, rmin=0.0, mode=1, lab_num=4, ntheta=12, col=BLACK)

Draw a polar coordinate grid with concentric circles and radial spokes.
- `mode`: 1 for linear, 0 for log/dB
- `lab_num`: number of concentric subdivisions
- `ntheta`: number of angular spokes (default 12 = every 30 degrees)
- `col`: grid color
"""
function polgrid(rmax::Real, rmin::Real=0.0, mode::Integer=1, lab_num::Integer=4, ntheta::Integer=12, col::Integer=BLACK)
    fn_ptr = Libdl.dlsym(_get_handle(), :polgrid)
    ccall(fn_ptr, Cvoid, (Cfloat, Cfloat, Cint, Ptr{Ptr{Cchar}}, Cint, Cint, Cint),
          Cfloat(rmax), Cfloat(rmin), Cint(mode), C_NULL, Cint(lab_num), Cint(ntheta), Cint(col))
end

"""
    polcurv(r, theta, n=min(length(r), length(theta)), sym=0)

Plot a curve in polar coordinates `(r, theta)`. `theta` is in radians.
"""
function polcurv(r::AbstractVector{<:Real}, theta::AbstractVector{<:Real}, n::Integer=min(length(r), length(theta)), sym::Integer=0)
    fr = Float32.(r[1:n])
    fth = Float32.(theta[1:n])
    fn_ptr = Libdl.dlsym(_get_handle(), :polcurve)
    ccall(fn_ptr, Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}, Cuint, Cint), fr, fth, Cuint(n), Cint(sym))
end
const polcurve = polcurv

"""Draw a box-and-whisker plot at x for data array y."""
function box_plot(x::Real, y::AbstractVector{<:Real}, outlier::Integer=1, symnum::Integer=1, width::Real=0.5)
    fy = Float32.(y)
    fn_ptr = Libdl.dlsym(_get_handle(), :BoxPlot)
    ccall(fn_ptr, Cvoid, (Cfloat, Ptr{Cfloat}, Cint, Cint, Cint, Cfloat),
          Cfloat(x), fy, Cint(length(fy)), Cint(outlier), Cint(symnum), Cfloat(width))
end
const BoxPlot = box_plot

"""
    bar(x, y; nxdiv=5, bwid=0.8, mode=0, colors=nothing, patterns=nothing)

Draw a 2D bar chart.
- `x`, `y`: coordinate vectors
- `nxdiv`: number of divisions along X axis
- `bwid`: bar width fraction (0.0 to 1.0)
- `mode`: 0 for standard, 10 for base-offset
- `colors`: vector of colors or symbols
- `patterns`: vector of fill pattern integers
"""
function bar(x::AbstractVector{<:Real}, y::AbstractVector{<:Real};
             nxdiv::Integer=5, bwid::Real=0.8, mode::Integer=0, colors=nothing, patterns=nothing)
    n = min(length(x), length(y))
    fx = Float32.(x[1:n])
    fy = Float32.(y[1:n])

    c_colors = if colors !== nothing
        Int32[resolve_color(c) for c in colors[1:min(length(colors), n)]]
    else
        fill(Int32(BLACK), n)
    end

    c_patterns = if patterns !== nothing
        Int32[Int32(p) for p in patterns[1:min(length(patterns), n)]]
    else
        fill(Int32(1), n)
    end

    fn_ptr = Libdl.dlsym(_get_handle(), :bar)
    ccall(fn_ptr, Cvoid,
          (Cint, Ptr{Cfloat}, Ptr{Cfloat}, Cint, Cfloat, Cint, Ptr{Cint}, Ptr{Cint}),
          Cint(nxdiv), fx, fy, Cint(n), Cfloat(bwid), Cint(mode),
          pointer(c_colors), pointer(c_patterns))
end

"""
    pie(values; captions=nothing, colors=nothing, offsets=nothing, size=2.0, border=1, textcolor=BLACK)

Draw a publication-quality 2D exploded pie chart.
- `values`: wedge values/percentages
- `captions`: vector of string slice labels
- `colors`: vector of slice colors
- `offsets`: vector of slice radial offsets (for exploding slices)
- `size`: diameter of pie chart in inches
- `border`: border outline flag
- `textcolor`: text label color
"""
function pie(values::AbstractVector{<:Real};
             captions=nothing, colors=nothing, offsets=nothing,
             size::Real=2.0, border::Integer=1, textcolor=BLACK)
    dim = length(values)
    fseg = Float32.(values)
    c_offsets = offsets !== nothing ? Float32.(offsets) : zeros(Float32, dim)

    c_colors = if colors !== nothing
        Int32[-abs(resolve_color(c)) for c in colors]
    else
        default_clrs = Int32[-4, -1, -2, -5, -3, -6, -7, -8]
        Int32[default_clrs[mod1(i, length(default_clrs))] for i in 1:dim]
    end

    c_caps = if captions !== nothing
        [Base.unsafe_convert(Cstring, String(c)) for c in captions]
    else
        [Base.unsafe_convert(Cstring, "") for _ in 1:dim]
    end

    fn_ptr = Libdl.dlsym(_get_handle(), :pieplot)
    GC.@preserve c_caps begin
        ccall(fn_ptr, Cvoid,
              (Cint, Ptr{Cfloat}, Ptr{Cint}, Ptr{Cfloat}, Ptr{Cstring}, Cfloat, Cint, Cint),
              Cint(dim), fseg, c_colors, c_offsets, pointer(c_caps), Cfloat(size), Cint(border), Cint(resolve_color(textcolor)))
    end
end

# Typography & Fonts
"""Load a vector or TrueType font by filename with escape character code."""
function font(fontname::AbstractString, esc::Union{Char, Integer}=200)
    c_esc = esc isa Char ? Int(UInt8(esc)) : Int(esc)
    fn_ptr = Libdl.dlsym(_get_handle(), :gpc_load_font)
    ccall(fn_ptr, Cvoid, (Cstring, UInt8), String(fontname), UInt8(c_esc))
end

"""Toggle solid filled font rendering (1 = filled, 0 = outline)."""
function fillfont(mode::Integer=1)
    fn_ptr = Libdl.dlsym(_get_handle(), :fillfont)
    ccall(fn_ptr, Cvoid, (Cint,), Cint(mode))
end

"""Configure font fill pattern and border color."""
function fontfill(fill::Integer=1, pattern::Integer=0, border::Integer=0)
    fn_ptr = Libdl.dlsym(_get_handle(), :fontfill)
    ccall(fn_ptr, Cvoid, (Cint, Cint, Cint), Cint(fill), Cint(pattern), Cint(border))
end

"""Set italicization slant angle for vector fonts."""
function skew(slant::Real)
    fn_ptr = Libdl.dlsym(_get_handle(), :skew)
    ccall(fn_ptr, Cvoid, (Cfloat,), Cfloat(slant))
end

"""Set character aspect ratio width expansion factor."""
function widen(factor::Real)
    fn_ptr = Libdl.dlsym(_get_handle(), :widen)
    ccall(fn_ptr, Cvoid, (Cfloat,), Cfloat(factor))
end

"""Plot formatted text in user coordinates."""
function pltfnt(x::Real, y::Real, text::AbstractString, height::Real=0.2, angle::Integer=0)
    fn_ptr = Libdl.dlsym(_get_handle(), :pltfnt)
    ccall(fn_ptr, Cvoid, (Cfloat, Cfloat, Cstring, Cfloat, Cint),
          Cfloat(x), Cfloat(y), String(text), Cfloat(height), Cint(angle))
end

"""Plot formatted text in physical inches."""
function prtfnt(xinch::Real, yinch::Real, text::AbstractString, height::Real=0.2, angle::Integer=0)
    fn_ptr = Libdl.dlsym(_get_handle(), :prtfnt)
    ccall(fn_ptr, Cvoid, (Cfloat, Cfloat, Cstring, Cfloat, Cint),
          Cfloat(xinch), Cfloat(yinch), String(text), Cfloat(height), Cint(angle))
end

"""Plot text in 3D perspective space."""
function d3pltfnt(x::Real, y::Real, z::Real, text::AbstractString, height::Real=0.2, angle::Integer=0)
    fn_ptr = Libdl.dlsym(_get_handle(), :d3pltfnt)
    ccall(fn_ptr, Cvoid, (Cfloat, Cfloat, Cfloat, Cstring, Cfloat, Cint),
          Cfloat(x), Cfloat(y), Cfloat(z), String(text), Cfloat(height), Cint(angle))
end

# Legend
"""Position the upper-left corner of the legend box in inches."""
function legpos(entries::Integer, xleg::Real, yleg::Real, border::Integer=1)
    fn_ptr = Libdl.dlsym(_get_handle(), :legpos)
    ccall(fn_ptr, Cvoid, (Cint, Cfloat, Cfloat, Cint), Cint(entries), Cfloat(xleg), Cfloat(yleg), Cint(border))
end

"""Add an entry to the active legend box."""
function legend(marker::Integer, str::AbstractString, style::Integer, strhgt::Real=0.15, scolor::Integer=BLACK)
    fn_ptr = Libdl.dlsym(_get_handle(), :legend)
    ccall(fn_ptr, Cvoid, (Cint, Cstring, Cint, Cfloat, Cint),
          Cint(marker), String(str), Cint(style), Cfloat(strhgt), Cint(scolor))
end

# Coordinate Conversions
"""Convert user data coordinates (x, y) to page physical inches."""
function usertoinch(x::Real, y::Real)
    xo = Ref{Cfloat}(0.0f0)
    yo = Ref{Cfloat}(0.0f0)
    fn_ptr = Libdl.dlsym(_get_handle(), :usertoinch)
    ccall(fn_ptr, Cvoid, (Cfloat, Cfloat, Ptr{Cfloat}, Ptr{Cfloat}), Cfloat(x), Cfloat(y), xo, yo)
    return (Float64(xo[]), Float64(yo[]))
end

"""Convert user data coordinates to device pixels."""
function usertopix(x::Real, y::Real, z::Real=0.0)
    xo = Ref{Cint}(0)
    yo = Ref{Cint}(0)
    fn_ptr = Libdl.dlsym(_get_handle(), :usertopix)
    ccall(fn_ptr, Cvoid, (Cfloat, Cfloat, Cfloat, Ptr{Cint}, Ptr{Cint}), Cfloat(x), Cfloat(y), Cfloat(z), xo, yo)
    return (Int(xo[]), Int(yo[]))
end

"""Convert device pixels to user data coordinates."""
function pixtouser(xp::Integer, yp::Integer)
    xo = Ref{Cfloat}(0.0f0)
    yo = Ref{Cfloat}(0.0f0)
    fn_ptr = Libdl.dlsym(_get_handle(), :pixtouser)
    ccall(fn_ptr, Cvoid, (Cint, Cint, Ptr{Cfloat}, Ptr{Cfloat}), Cint(xp), Cint(yp), xo, yo)
    return (Float64(xo[]), Float64(yo[]))
end

"""Convert physical page inches to device pixels."""
function intopix(inches::Real)
    fn_ptr = Libdl.dlsym(_get_handle(), :intopix)
    return Int(ccall(fn_ptr, Cint, (Cfloat,), Cfloat(inches)))
end

"""Convert device pixels to physical page inches."""
function pixtoin(pixels::Integer)
    fn_ptr = Libdl.dlsym(_get_handle(), :pixtoin)
    return Float64(ccall(fn_ptr, Cfloat, (Cint,), Cint(pixels)))
end

# System Integration
"""Open SVG plot in default browser or system viewer."""
function svgopen(filepath::Union{AbstractString, Nothing}=nothing)
    p = filepath === nothing ? (isempty(CURRENT_OUTPUT[]) ? C_NULL : CURRENT_OUTPUT[]) : String(filepath)
    fn_ptr = Libdl.dlsym(_get_handle(), :svgopen)
    return Int(ccall(fn_ptr, Cint, (Cstring,), p))
end

"""Push SVG plot over HTTP/HTTPS (POST) to an endpoint."""
function svgpush(url::Union{AbstractString, Nothing}=nothing, filepath::Union{AbstractString, Nothing}=nothing)
    u = url === nothing ? C_NULL : String(url)
    p = filepath === nothing ? (isempty(CURRENT_OUTPUT[]) ? C_NULL : CURRENT_OUTPUT[]) : String(filepath)
    fn_ptr = Libdl.dlsym(_get_handle(), :svgpush)
    return Int(ccall(fn_ptr, Cint, (Cstring, Cstring), u, p))
end

# Continuous Colormaps
"""Evaluate a 24-bit TrueColor hex integer across continuous colormaps."""
function colormap_eval(map_id::Integer, t::Real)
    fn_ptr = Libdl.dlsym(_get_handle(), :gpc_colormap_eval)
    ccall(fn_ptr, Cint, (Cint, Cfloat), Cint(map_id), Cfloat(t))
end

"""Draw a continuous calibration color key gradient bar."""
function colorkey_gradient(minv::Real, maxv::Real, colormap::Integer,
                           llx::Real, lly::Real, urx::Real, ury::Real,
                           nticks::Integer=5, format::AbstractString="%4.2f",
                           fontc::Union{Char, Integer}=200, height::Real=0.15, angle::Integer=0)
    c_font = fontc isa Char ? Int(UInt8(fontc)) : Int(fontc)
    fn_ptr = Libdl.dlsym(_get_handle(), :ColorKeyGradient)
    ccall(fn_ptr, Cvoid,
          (Cfloat, Cfloat, Cint, Cfloat, Cfloat, Cfloat, Cfloat, Cint, Cstring, UInt8, Cfloat, Cint),
          Cfloat(minv), Cfloat(maxv), Cint(colormap),
          Cfloat(llx), Cfloat(lly), Cfloat(urx), Cfloat(ury),
          Cint(nticks), String(format), UInt8(c_font), Cfloat(height), Cint(angle))
end

# ==============================================================================
# High-Level Idiomatic Julia Interface
# ==============================================================================

function _nice_step(range_val::Real, n_target::Integer=5)
    raw_step = range_val / n_target
    mag = 10.0^floor(log10(max(raw_step, 1e-12)))
    norm = raw_step / mag
    step = norm < 1.5 ? 1.0 : (norm < 3.5 ? 2.0 : (norm < 7.5 ? 5.0 : 10.0))
    return step * mag
end

"""
    plot(x, y; kwargs...)

High-level one-line plotting for Julia.
Automatically configures page layout, scales, axes, labels, styling, and crops the SVG.
Returns a `PlotOutput` object that renders inline in Jupyter / Pluto / VS Code.

# Keyword Arguments:
- `title::String`: Plot heading
- `xlabel::String`: Horizontal axis label
- `ylabel::String`: Vertical axis label
- `color`: Line/marker color (e.g. :blue, :red, GraphiC.BLUE, or 0xRRGGBB)
- `ltype`: Line pattern (:solid, :dashed, :dotted, etc.)
- `thick::Real`: Stroke width (default 1.0)
- `symbol`: Marker symbol (:circle, :square, :diamond, etc., or nothing)
- `width::Real`, `height::Real`: Page dimensions in inches (default 8.0 x 6.0)
- `filename::String`: Output SVG path (default "graphic_plot.svg")
- `crop::Bool`: Auto-crop SVG tightly with margin (default true)
- `grid::Bool`: Draw Cartesian grid (default false)
"""
function plot(x::AbstractVector{<:Real}, y::AbstractVector{<:Real};
              title::AbstractString="", xlabel::AbstractString="", ylabel::AbstractString="",
              color=BLACK, ltype=SOLID, thick::Real=1.0, symbol=nothing,
              width::Real=8.0, height::Real=6.0, filename::AbstractString="graphic_plot.svg",
              crop::Bool=true, margin::Real=0.25, grid::Bool=false,
              xmin=nothing, xmax=nothing, xstep=nothing,
              ymin=nothing, ymax=nothing, ystep=nothing)
    n = min(length(x), length(y))
    if n == 0
        error("Cannot plot empty vectors")
    end

    # Auto-scaling
    x_min = xmin === nothing ? minimum(x[1:n]) : Float64(xmin)
    x_max = xmax === nothing ? maximum(x[1:n]) : Float64(xmax)
    if x_min == x_max
        x_min -= 1.0
        x_max += 1.0
    end
    x_step = xstep === nothing ? _nice_step(x_max - x_min, 5) : Float64(xstep)

    y_min = ymin === nothing ? minimum(y[1:n]) : Float64(ymin)
    y_max = ymax === nothing ? maximum(y[1:n]) : Float64(ymax)
    if y_min == y_max
        y_min -= 1.0
        y_max += 1.0
    end
    y_step = ystep === nothing ? _nice_step(y_max - y_min, 5) : Float64(ystep)

    bgnplot(1, 'S', filename)
    try
        page(width, height)
        startplot(WHITE)
        if crop
            svgcrop(margin)
        end
        area2d(width * 0.75, height * 0.72)
        physor(width * 0.15, height * 0.14)
        box()

        graf("%g", x_min, x_step, x_max, "%g", y_min, y_step, y_max)
        if grid
            GraphiC.grid(1)
        end
        GraphiC.title(title, xlabel, ylabel)

        clr = resolve_color(color)
        GraphiC.color(clr)
        tiline(thick)

        lt = resolve_ltype(ltype)
        curve(x, y, n, lt)

        if symbol !== nothing
            sym_id = resolve_symbol(symbol)
            sympick(sym_id)
            for i in 1:n
                GraphiC.symbol(x[i], y[i], sym_id)
            end
        end
    finally
        endplot()
        stopplot()
    end

    return PlotOutput(CURRENT_OUTPUT[])
end

"""
    scatter(x, y; kwargs...)

High-level scatter plot for Julia. Equivalent to `plot(x, y; ltype=-1, symbol=symbol, ...)`.
"""
function scatter(x::AbstractVector{<:Real}, y::AbstractVector{<:Real};
                 symbol=:circle, color=:blue, kwargs...)
    return plot(x, y; symbol=symbol, color=color, ltype=-1, kwargs...)
end

"""
    surface_plot(z; kwargs...)

High-level 3D surface plot from a matrix.
"""
function surface_plot(z::AbstractMatrix{<:Real};
                      title::AbstractString="", xlabel::AbstractString="", ylabel::AbstractString="", zlabel::AbstractString="",
                      vu=[8.0, -8.0, 6.0], width::Real=8.0, height::Real=6.0,
                      filename::AbstractString="graphic_surface.svg", crop::Bool=true, margin::Real=0.25)
    nx, ny = size(z, 1), size(z, 2)
    bgnplot(1, 'S', filename)
    try
        page(width, height)
        startplot(WHITE)
        if crop
            svgcrop(margin)
        end
        area2d(width * 0.72, height * 0.72)
        physor(width * 0.15, height * 0.15)
        volm3d(5.0, 5.0, 4.0)
        vuabs(vu[1], vu[2], vu[3])

        zmin, zmax = extrema(z)
        zstep = _nice_step(zmax - zmin, 4)

        graf3d(1.0, 1.0, Float64(nx), 1.0, 1.0, Float64(ny), zmin, zstep, zmax)
        GraphiC.title(title, xlabel, ylabel)
        if !isempty(zlabel)
            z3name(zlabel)
        end
        color(BLACK)
        surface(z, nx, ny)
    finally
        endplot()
        stopplot()
    end

    return PlotOutput(CURRENT_OUTPUT[])
end

"""
    contour_plot(z; kwargs...)

High-level 2D contour plot from a matrix.
"""
function contour_plot(z::AbstractMatrix{<:Real};
                      x=1:size(z,1), y=1:size(z,2),
                      title::AbstractString="", xlabel::AbstractString="", ylabel::AbstractString="",
                      nlevels::Integer=10, width::Real=8.0, height::Real=6.0,
                      filename::AbstractString="graphic_contour.svg", crop::Bool=true, margin::Real=0.25)
    nx, ny = size(z, 1), size(z, 2)
    xcoords = collect(x)
    ycoords = collect(y)

    zmin, zmax = extrema(z)
    step = (zmax - zmin) / nlevels

    bgnplot(1, 'S', filename)
    try
        page(width, height)
        startplot(WHITE)
        if crop
            svgcrop(margin)
        end
        area2d(width * 0.75, height * 0.72)
        physor(width * 0.15, height * 0.14)
        box()

        xstep = _nice_step(maximum(xcoords) - minimum(xcoords), 5)
        ystep = _nice_step(maximum(ycoords) - minimum(ycoords), 5)
        graf("%g", minimum(xcoords), xstep, maximum(xcoords),
             "%g", minimum(ycoords), ystep, maximum(ycoords))
        GraphiC.title(title, xlabel, ylabel)
        color(BLACK)

        contour(z, xcoords, nx, ycoords, ny, zmin, step, zmax, 1)
    finally
        endplot()
        stopplot()
    end

    return PlotOutput(CURRENT_OUTPUT[])
end

end # module GraphiC
