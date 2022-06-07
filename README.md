![glyphy splash image](docs/src/assets/figures/glyphy-social-media-preview.png)

| **Documentation**                       | **Build Status**                          | **Code Coverage**               |
|:---------------------------------------:|:-----------------------------------------:|:-------------------------------:|
| [![][docs-stable-img]][docs-stable-url] | [![Build Status][ci-img]][ci-url]         |  |
| [![][docs-development-img]][docs-development-url] | |      

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

[docs-development-img]: https://img.shields.io/badge/docs-development-blue
[docs-development-url]: http://cormullion.github.io/glyphy.jl/dev/

[docs-stable-img]: https://img.shields.io/badge/docs-stable-blue.svg
[docs-stable-url]: http://cormullion.github.io/glyphy.jl/stable/

[ci-img]: https://github.com/cormullion/glyphy.jl/workflows/CI/badge.svg
[ci-url]: https://github.com/cormullion/glyphy.jl/actions?query=workflow%3ACI
