using Glyphy
using Test

@testset "Glyphy.jl" begin
    glyphy("peacock")
    glyphy("cat")
    glyphy(0x33)
    glyphy(0x33:0x43)
    glyphy(0xffee:0xffff)
    glyphy([43])
    glyphy([43, 123, 2341, 12])

    @testset "array output" begin
        @test all(size(glyphy("and"; output=:array)) .>= (200, 5))
        @test glyphy("peacock"; output=:array) == ["1f99a" '🦚' false "peacock" ":peacock:"]
        @test glyphy(0x20ac; output=:array) == ["020ac" '€' true "euro sign" "euro"]
        @test glyphy(0x3a:0x3b; output=:array) == ["0003a" ':' true "colon" ""; "0003b" ';' true "semicolon" ""]
    end
end
