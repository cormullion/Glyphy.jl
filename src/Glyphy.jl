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
        d = Dictionary{Int,String}()
        for l in split(raw, '\n')
            unicode, name = split(l, ';')[1:2]
            if name == "<control>"
                continue
            end
            unicodeval = parse(Int, unicode, base = 16)
            insert!(d, unicodeval, lowercase(name))
        end
        d
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
    print(lpad(string(unicodepoint, base = 16), 6))
    print(lpad(Char(unicodepoint), 4))
    print(textwidth(Char(unicodepoint)) == 2 ? "  " : " ")
    if unicodepoint ∈ coverage
        print(lpad("✓", 2))
    else
        print("  ")
    end
    print("    ")
    print(rpad(name, 60))
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

Searches are case-insentive regular expressions (ie `Regex(string, "i")`).

The "✓" indicates that the glyph is available in the JuliaMono font.

If there are a lot of results, use the `showall = true` option to see them all.
"""
function glyphy(s::String;
        showall = false )
    # filter looks at values
    hitvalues = filter(v -> occursin(Regex(s, "i"), v), unicodedict)
    # result is another Dictionary{Int64, String}
    if isempty(hitvalues)
        println("0 results")
        return
    end
    if length(hitvalues) > 100 && showall == false
        println("There were $(length(hitvalues)) results for \"$(s)\"")
        println("Use the `showall = true` option to see them all.")
        return
    end
    println()
    for hitvalue in pairs(hitvalues)
        unicodepoint = first(hitvalue)
        unicodename = last(hitvalue)
        _printentry(unicodepoint, unicodename)
    end
    if length(hitvalues) > 1
        println("found $(length(hitvalues)) glyphs matching \"$(s)\"")
    else
        println("found one glyph matching \"$(s)\"")
    end
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
function glyphy(i;
        image = false,
        grid = 15)
    unicodepoint = i
    unicodename = unicodedict[i]
    println()
    _printentry(unicodepoint, unicodename)
    if haskey(reverse_latex_dict, Int(Char(unicodepoint)))
        print("You can enter this glyph by typing \\")
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
        face = FTFont("/Users/pete/Library/Fonts/JuliaMono-Light.ttf")
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
end

end
