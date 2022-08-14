using Glyphy
using Test

@testset "Glyphy.jl" begin
    glyphy("peacock")
    glyphy("cat")
    glyphy(33)
end
