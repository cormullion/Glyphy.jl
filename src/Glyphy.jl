"""
Glyphy searches its Unicode glyph database.

```julia
julia> glyphy("watermelon|tangerine")

1f349   🍉     watermelon
1f34a   🍊     tangerine
found 2 glyphs matching "watermelon|tangerine"
```
"""
module Glyphy

using Colors
using Dictionaries
using FixedPointNumbers
using FreeType
using FreeTypeAbstraction
using ImageInTerminal

using REPL.REPLCompletions: emoji_symbols, latex_symbols

export glyphy

function _build_coverage_list(fontpath)
    library = Ref{FT_Library}()
    error = FT_Init_FreeType(library)
    refface = Ref{FT_Face}()
    FT_New_Face(library[], fontpath, 0, refface)
    glyphcodes = Int[]
    for char in 0x1:0x20000
        glyph_index = FT_Get_Char_Index(refface[], char)
        if glyph_index != 0
            FT_Load_Glyph(refface[], glyph_index, FT_LOAD_NO_SCALE)
            face = unsafe_load(refface[])
            glyph = unsafe_load(face.glyph)
            # only count the ones that have some graphics
            if glyph.outline.n_contours > 0
                push!(glyphcodes, char)
            end
        end
    end
    return glyphcodes
end

function _build_dictionary()
    unicodedict = open(dirname(dirname(pathof(Glyphy))) * "/data/unicodedata.txt", "r") do f
        raw = read(f, String)
        dict = Dictionary{Int,String}()
        for l in split(raw, '\n')
            isempty(l) && continue
            unicode, name = split(l, ';')[1:2]
            if name == "<control>"
                 continue
            end
            unicodeval = parse(Int, unicode, base = 16)
            set!(dict, unicodeval, lowercase(name))
        end
        dict
    end
    open(dirname(dirname(pathof(Glyphy))) * "/data/juliamonoprivateusage.txt", "r") do f
        raw = read(f, String)
        for l in split(raw, '\n')
            isempty(l) && continue
            unicode, name = split(l, ';')[1:2]
            unicodeval = parse(Int, unicode, base = 16)
            set!(unicodedict, unicodeval, lowercase(name))
        end
    end
    return unicodedict
end

const unicodedict = _build_dictionary()
const coverage = _build_coverage_list(dirname(dirname(pathof(Glyphy))) * "/data/JuliaMono-Light.ttf")
const reverse_emoji_dict = Dictionary{Integer,String}()
const reverse_latex_dict = Dictionary{Integer,String}()

[set!(reverse_emoji_dict, Int(Char(v[1])), k[2:end]) for (k, v) in emoji_symbols]
[set!(reverse_latex_dict, Int(Char(v[1])), k[2:end]) for (k, v) in latex_symbols]

function _printentry(unicodepoint, name)
    space = string(Char(32))
    print(lpad(string(unicodepoint, base = 16), 5, "0"))
    print(space ^ textwidth(Char(unicodepoint)))
    print(lpad(Char(unicodepoint), 3))
    if unicodepoint ∈ coverage
        print(lpad("✓", 3))
    else
        print(space ^ 3)
    end
    print(space ^ 2)
    print(name)
    println()
end

"""
    glyphy(string)

Find glyphs with `string` in the name.

For example:

```julia
julia> glyphy("smash")

  2a33   ⨳  ✓    smash product
  2a50   ⩐  ✓    closed union with serifs and smash product
found 2 glyphs matching "smash"
```

Searches are case-insensitive. You can also supply regular
expressions. So, if the search string contains special
characters such as `*` or `|`, the search will be made using
regular expressions.

The "✓" indicates that the glyph is available in the JuliaMono font.

If there are a lot of results, use the `showall = true` option to see them all.

Excluded: "<control>" characters.
"""
function glyphy(s::String;
        showall = false )
    # filter looks at values
    # if it doesn't look like a regex
    if all(c -> isletter(c) || isdigit(c) || isspace(c) || isequal(c, "-"), map(Char, s)) == true
        # don't do a regex
        hitvalues = filterview(v -> occursin(s, v), unicodedict)
    else
        # do a regex
        hitvalues = filterview(v -> occursin(Regex(s, "i"), v), unicodedict)
    end
    # result is another Dictionary{Int64, String}
    if isempty(hitvalues)
        println("0 results")
        return
    end
    println()
    n = 1
    for hitvalue in pairs(hitvalues)
        unicodepoint = first(hitvalue)
        unicodename = last(hitvalue)
        _printentry(unicodepoint, unicodename)
        if showall == false
            if n >= 50 && length(hitvalues) > 80
                println(" showing the first $(n) of $(length(hitvalues)) results for \"$(s)\"")
                println(" Use the `showall = true` option to see them all.")
                return
            end
        end
        n += 1
    end
    if length(hitvalues) > 1
        println(" found $(length(hitvalues)) glyphs matching \"$(s)\"")
    else
        println(" found one glyph matching \"$(s)\"")
    end
    hitvalues = nothing # does this help with the slow performance?
    return nothing
end

"""
    glyphy(int;
        image = false,
        grid = 15)

Find glyph number `int` in the Unicode chart.

For example:

```julia
glyphy(0x123)

   123   ģ  ✓    latin small letter g with cedilla
```

The "✓" indicates that the glyph is available in the JuliaMono font.
"""
function glyphy(unicodepoint::T where T <: Number;
        image = false,
        grid = 15)
    if !haskey(unicodedict, unicodepoint)
        println(" can't find code point at 0x$(string(unicodepoint, base=16))")
        return nothing
    end
    unicodename = unicodedict[unicodepoint]
    println()
    _printentry(unicodepoint, unicodename)
    if haskey(reverse_latex_dict, Int(Char(unicodepoint)))
        print(" You can enter this glyph by typing \\")
        print(reverse_latex_dict[Int(Char(unicodepoint))])
        println("TAB")
    end
    if haskey(reverse_emoji_dict, Int(Char(unicodepoint)))
        print("You can enter this glyph by typing \\")
        print(reverse_emoji_dict[Int(Char(unicodepoint))])
        println("TAB")
    end
    # if the glyph is in JuliaMono, we can image it now
    if image == true && unicodepoint ∈ coverage
        face = FTFont(dirname(dirname(pathof(Glyphy))) * "/data/JuliaMono-Light.ttf")
        img, metric = renderface(face, Char(unicodepoint), grid)
        imgg = reinterpret(N0f8, permutedims(img, (2, 1)))
        println()
        ImageInTerminal.imshow(Gray.(imgg))
        println()
    elseif image == true
        # we can't at the moment use FreeType unless we know which font has this character
        # which gets into the font finding rigmarole
        # besides, this is mostly for me testing JuliaMono :)
        if unicodepoint ∉ coverage
            # oh, glyph is not in JuliaMono
            println()
        end
    end
    return nothing
end

# for debugging
function showdict()
    return unicodedict
end

end
