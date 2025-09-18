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

    # print shortcut
    if length(q.shortcut) > 0
        print(" ⌨ ")
        print("\\")
        print(q.shortcut)
    end
    println()
end

"""
    glyphy(s::String; showall=false, shortcut=true)

Find glyphs with `string` in the name.

For example:

```julia
julia> glyphy("smash")

02a33   ⨳   ✓    smash product ⌨ \\smashtimes
02a50   ⩐   ✓    closed union with serifs and smash product ⌨ \\closedvarcupsmashprod
 found 2 glyphs matching "smash"
```

If there are a lot of results, use the `showall = true`
option to see them all.

The "✓" indicates that the glyph is available in the JuliaMono font.
"pua" = Private Use Area.

If there's a keyboard shortcut in the Julia REPL,
it's shown after the `⌨`.

The characters with "<control>" in the name aren't included.
The `shortcut` keyword is ignored.
"""
function glyphy(s::String; output=:stdout, showall=(output==:stdout ? false : true), shortcut=true)
    if all(c -> isletter(c) || isdigit(c) || isspace(c) || isequal(c, '-') || isequal(c, '<'), map(Char, s)) == true
        ## if it doesn't look like a real regex, do sqlite-y match
        findstatement = "select * from unicodechart where name like '%$s%' ESCAPE '`';"
    else
        # let's go full regex
        findstatement = "select * from unicodechart where regexp('$s', name);"
    end
    q = _query_db(findstatement)
    if output == :array
        retval = similar([], showall ? length(q) : min(length(q), 50), 5)
        r = 1
        for row in q
            retval[r, 1] = lpad(string(row.id, base=16), 5, "0")
            retval[r, 2] = Char(row.id)
            retval[r, 3] = row.juliamono |> Bool
            retval[r, 4] = row.name
            retval[r, 5] = row.shortcut
            r >= size(retval, 1) && break
            r += 1
        end
        return retval
    end
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
    glyphy(r::UnitRange)

Find the glyph numbers in the range `r` in the Unicode chart.

For example:

```julia
glyphy(0x0:0x7F)

00020            space
00021   !   ✓    exclamation mark
00022   "   ✓    quotation mark
00023   #   ✓    number sign
...
0007b   {   ✓    left curly bracket
0007c   |   ✓    vertical line
0007d   }   ✓    right curly bracket
0007e   ~   ✓    tilde
```

Empty glyphs are usually omitted, so 0x7F ("DELETE") isn't listed.
"""
function glyphy(r::UnitRange)
    findstatement = "select * from unicodechart where id >= '$(r.start)' and id <= '$(r.stop)';"
    q = Glyphy._query_db(findstatement)
    if length(q) == 0
        println(" can't find anything in the range 0x$(lpad(string(r.start, base=16), 5, string(0))) to 0x$(lpad(string(r.stop, base=16), 5, string(0)))")
        return nothing
    end
    println()
    for (n, qe) in enumerate(q)
        Glyphy._printentry(qe)
    end 
    return nothing
end

"""
    glyphy(a::Array)

Find the glyph numbers in the array `a` in the Unicode chart.

For example:

```julia
glyphy([0x2311, 0x3124, 0x6742, 0xa100])

02311   ⌑   ✓    square lozenge ⌨ \\sqlozenge
03124   ㄤ       bopomofo letter ang
0a100   ꄀ       yi syllable dit
```
"""
function glyphy(a::Array{T, 1} where {T<:Integer})
    s = IOBuffer()
    for (i, n) in enumerate(a)
        write(s, "'")
        write(s, string(n))
        write(s, "'")
        i < length(a) && write(s, ", ")
    end 
    values = String(take!(s))    
    findstatement = "select * from unicodechart where id in ( $(values) );"
    q = Glyphy._query_db(findstatement)
    if length(q) == 0
        println(" can't find anything for any of these glyph numbers")
        return nothing
    end
    println()
    for (n, qe) in enumerate(q)
        Glyphy._printentry(qe)
    end 
    return nothing
end


"""
   glyphy(unicodepoint::T where {T<:Integer})

Find glyph number `int` in the Unicode chart.

For example:

```julia
glyphy(0x123)

00123   ģ   ✓    latin small letter g with cedilla
```

The `✓` indicates that the glyph is available in the JuliaMono font.

```julia
julia> glyphy(0x2311)

02311   ⌑   ✓    square lozenge ⌨ \\sqlozenge
```

It's usual to supply glyph numbers in hexadecimal, eg `0x...`. 

```julia
glyphy(123)

0007b   {   ✓    left curly bracket
```
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
    return nothing
end


Base.precompile(glyphy, (Int,))
Base.precompile(glyphy, (String,))

end
