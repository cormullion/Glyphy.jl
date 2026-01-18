#= script to build the glyphs database =#

using Pkg

Pkg.activate("Glyphy", shared=true)
Pkg.add.(["SQLite", "LazyJSON", "Colors", "FixedPointNumbers", "FreeType", "FreeTypeAbstraction", "REPL"])

using SQLite, LazyJSON, Colors, FixedPointNumbers, FreeType, FreeTypeAbstraction, REPL

function createdatabase(dbpathname)
    if isfile(dbpathname)
        rm(dbpathname)
    end
    db = SQLite.DB(dbpathname)
    DBInterface.execute(db, "CREATE TABLE unicodechart(id INTEGER PRIMARY KEY, name TEXT, juliamono INTEGER, shortcut TEXT)")
    @info "created new database in $dbpathname"
end

function sqlanitize(s)
    s = replace(s, "\'" => "''") # replace a single quote with two
    s = replace(s, "\\\"" => "\"") # don't need to escape double quote now
    return s
end

function opendatabase(dbpathname)
    db = SQLite.DB(dbpathname)
    return db
end

function insert_into_db(db, unicodeval, name, covered)
    # unicodevale is an integer
    # name is a string

    if haskey(reverse_latex_dict, unicodeval)
        short = reverse_latex_dict[unicodeval]
    elseif haskey(reverse_emoji_dict, unicodeval)
        short = reverse_emoji_dict[unicodeval]
    else
        short = ""
    end

    DBInterface.execute(
        db,
        "INSERT OR IGNORE INTO unicodechart(id, name, juliamono, shortcut) VALUES (
            '$(unicodeval)',
            '$(sqlanitize(name))',
            '$(covered)',
            '$(sqlanitize(short))'
            )",
    )
end

function _build_coverage_list(fontpath)
    @info " finding coverage for $fontpath"
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

function _build_database(db)
    @info " ...building database"
    open(joinpath(@__DIR__, "unicodedata.txt"), "r") do f
        raw = read(f, String)
        for l in split(raw, '\n')
            isempty(l) && continue
            unicode, name = split(l, ';')[1:2]
            if name == "<control>"
                continue
            end
            unicodeval = parse(Int, unicode, base=16)
            covered = unicodeval ∈ coverage ? 1 : 0
            insert_into_db(db, unicodeval, lowercase(name), covered)
        end
    end
    @info "Loading private usage details..."
    open(joinpath(@__DIR__, "juliamonoprivateusage.txt"), "r") do f
        raw = read(f, String)
        for l in split(raw, '\n')
            isempty(l) && continue
            unicode, name = split(l, ';')[1:2]
            unicodeval = parse(Int, unicode, base=16)
            covered = unicodeval ∈ coverage ? 1 : 0
            insert_into_db(db, unicodeval, lowercase(name), covered)
        end
    end
end

dbpath = joinpath(@__DIR__, "glyphs.db")
@info "creating database at $(dbpath)"
createdatabase(dbpath)
db = opendatabase(dbpath)

const reverse_emoji_dict = Dict{Integer,String}()
@info " doing emojis"
[reverse_emoji_dict[Int(Char(v[1]))] = k[2:end] for (k, v) in REPL.REPLCompletions.emoji_symbols]

const reverse_latex_dict = Dict{Integer,String}()
@info " doing LaTeX completions"
[reverse_latex_dict[Int(Char(v[1]))] = k[2:end] for (k, v) in REPL.REPLCompletions.latex_symbols]


@info " getting glyphs from font"
const coverage = _build_coverage_list(joinpath(@__DIR__, "JuliaMono-Light.ttf"))

@info " build database..."
const unicodedb = _build_database(db)

@info "finished building glyphs database - it's at $dbpath"
