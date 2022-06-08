![glyphy splash image](docs/src/assets/figures/glyphy-social-media-preview.png)

# Glyphy

Glyphy is a small utility package that runs in the Julia REPL.

Glyphy searches through the names of glyphs in the Unicode
system and returns a list of the glyph names that match the
search string.

```julia
using Glyphy
julia>  glyphy("peacock")

 1f99a  🦚        peacock           
found one glyph matching "peacock"
```

There might be a few:

```julia
julia> glyphy("flower")

 2055   ⁕  ✓  flower punctuation mark  
 2698   ⚘  ✓  flower                   
1f33b   🌻     sunflower                
1f395   🎕     bouquet of flowers       
1f3b4   🎴     flower playing cards     
1f4ae   💮     white flower             
1f940   🥀     wilted flower            
found 7 glyphs matching "flower"
```

Here, the check mark indicates that the glyph is defined in the current release of
the JuliaMono font (it doesn't know which font you're currently using in your
terminal).

Glyphy can also look for the glyph with a specific integer
code point. It's usual to type them as hexadecimal integers,
so `0x2055`, `0x1f99a`, etc.


```julia
julia> glyphy(0x1f99a)

1f99a  🦚        peacock              
You can enter this glyph by typing \:peacock:TAB
```

[docs-development-img]: https://img.shields.io/badge/docs-development-blue
[docs-development-url]: http://cormullion.github.io/glyphy.jl/dev/

[docs-stable-img]: https://img.shields.io/badge/docs-stable-blue.svg
[docs-stable-url]: http://cormullion.github.io/glyphy.jl/stable/

[ci-img]: https://github.com/cormullion/glyphy.jl/workflows/CI/badge.svg
[ci-url]: https://github.com/cormullion/glyphy.jl/actions?query=workflow%3ACI
