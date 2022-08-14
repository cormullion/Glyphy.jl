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

using SQLite
using Tables

export glyphy

function _query_db(querystring)
    db = SQLite.DB(dirname(dirname(pathof(Glyphy))) * "/data/glyphs.db")
    SQLite.@register db SQLite.regexp
    q = DBInterface.execute(db, querystring) |> rowtable
    return q
end

function _printentry(q)
    space = string(Char(32))
    print(lpad(string(q.id, base=16), 5, "0"))
    print(space^textwidth(Char(q.id)))
    print(lpad(Char(q.id), 3))
    # use these things to move the "cursor", since width calculations are tricky
    print("\e[13G")
    if q.juliamono > 0
        print("✓")
    else
        print(space)
    end
    print("\e[16G")
    print(space^2)
    print(q.name)
    println()
end

"""
    glyphy(s::String; showall=false)

Find glyphs with `string` in the name.

For example:

```julia
julia> glyphy("smash")

  2a33   ⨳  ✓    smash product
  2a50   ⩐  ✓    closed union with serifs and smash product
found 2 glyphs matching "smash"
```

If there are a lot of results, use the `showall = true`
option to see them all.

The "✓" indicates that the glyph is available in the JuliaMono font.
"pua" = Private Use Area.

```julia
julia> glyphy("smash")

02a33   ⨳   ✓    smash product
02a50   ⩐   ✓    closed union with serifs and smash product
 found 2 glyphs matching "smash"
```

Excluded: "<control>" characters.
"""
function glyphy(s::String; showall=false)
    if all(c -> isletter(c) || isdigit(c) || isspace(c) || isequal(c, '-') || isequal(c, '<'), map(Char, s)) == true
        ## if it doesn't look like a real regex, do sqlite-y match
        findstatement = "select * from unicodechart where name like '%$s%' ESCAPE '`';"
    else
        # let's go full regex
        findstatement = "select * from unicodechart where regexp('$s', name);"
    end
    q = _query_db(findstatement)
    if length(q) == 0
        println("0 results")
        return
    end
    println()
    n = 1
    for row in q
        _printentry(row)
        if showall == false
            if n >= 50 && length(q) > 80
                println(" showing the first $(n) of $(length(q)) results for \"$(s)\"")
                println(" Use the `showall = true` option to see them all.")
                return
            end
        end
        n += 1
    end
    if length(q) > 1
        println(" found $(length(q)) glyphs matching \"$(s)\"")
    else
        println(" found one glyph matching \"$(s)\"")
    end
    return nothing
end

"""
    glyphy(int)

Find glyph number `int` in the Unicode chart.

For example:

```julia
glyphy(0x123)

00123   ģ   ✓    latin small letter g with cedilla
```

The `✓` indicates that the glyph is available in the JuliaMono font.
If there's a Julia REPL short-cut for typing it, it's shown below:

```
julia> glyphy(0x2311)

02311   ⌑   ✓    square lozenge
 You can enter this glyph by typing \\sqlozenge TAB
````
"""
function glyphy(unicodepoint::T where {T<:Integer})
    findstatement = "select * from unicodechart where id = '$unicodepoint';"
    q = _query_db(findstatement)
    if length(q) == 0
        println(" can't find anything at 0x$(string(unicodepoint, base=16))")
        return nothing
    end
    println()
    _printentry(q[1])
    if q[1].shortcut != ""
        print(" You can enter this glyph by typing \\")
        print(q[1].shortcut)
        println(" TAB")
    end
    return nothing
end

Base.precompile(glyphy, (Int,))
Base.precompile(glyphy, (String,))

end
