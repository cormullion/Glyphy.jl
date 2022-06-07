![glyphy splash image](docs/src/assets/figures/glyphy-social-media-preview.png)

<!--
| **Documentation**                       | **Build Status**                          | **Code Coverage**               |
|:---------------------------------------:|:-----------------------------------------:|:-------------------------------:|
| [![][docs-stable-img]][docs-stable-url] | [![Build Status][ci-img]][ci-url]         |  |
| [![][docs-development-img]][docs-development-url] | |      

-->

# Glyphy

Glyphy is a small utility package that runs in the Julia REPL.

Glyphy searches through the names of glyphs in the Unicode system and returns a list that matches the search string.

```julia
using Glyphy
julia>  glyphy("peacock")

 1f99a  🦚        peacock           
found one glyph matching "peacock"
```

Glyphy can also look for the glyph that corresponds to an integer (typing them in hexadecimal is usual).

```julia
julia> glyphy(0x1f99a)

1f99a  🦚        peacock              
You can enter this glyph by typing \:peacock:TAB
```

```julia
julia> glyphy("flower")

  2055   ⁕  ✓    flower punctuation mark                                     
  2698   ⚘  ✓    flower                                                      
 1f33b  🌻        sunflower                                                   
 1f395   🎕       bouquet of flowers                                          
 1f3b4  🎴        flower playing cards                                        
 1f4ae  💮        white flower                                                
 1f940  🥀        wilted flower                                               
found 7 glyphs matching "flower"
```

The check marks indicate that the glyph is defined in the current release of
the JuliaMono font (it doesn't know which font you're currently using in your
terminal).

[docs-development-img]: https://img.shields.io/badge/docs-development-blue
[docs-development-url]: http://cormullion.github.io/glyphy.jl/dev/

[docs-stable-img]: https://img.shields.io/badge/docs-stable-blue.svg
[docs-stable-url]: http://cormullion.github.io/glyphy.jl/stable/

[ci-img]: https://github.com/cormullion/glyphy.jl/workflows/CI/badge.svg
[ci-url]: https://github.com/cormullion/glyphy.jl/actions?query=workflow%3ACI
