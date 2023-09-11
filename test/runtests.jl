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
end
