![glyphy splash image](docs/src/assets/figures/glyphy-social-media-preview.png)

# Glyphy

Glyphy is a small utility package that searches through the names of glyphs in the Unicode
glyph list and returns a list of the glyph names that match
the search string.

```julia
using Glyphy
julia> glyphy("peacock")

1f99a   🦚       peacock
 found one glyph matching "peacock"
```

There might be a few:

```
julia> glyphy("smiling")

0263a   ☺   ✓     white smiling face
0263b   ☻   ✓     black smiling face
1f601   😁        grinning face with smiling eyes
1f603   😃        smiling face with open mouth
1f604   😄        smiling face with open mouth and smiling eyes
1f605   😅        smiling face with open mouth and cold sweat
1f606   😆        smiling face with open mouth and tightly-closed eyes
1f607   😇        smiling face with halo
1f608   😈        smiling face with horns
1f60a   😊        smiling face with smiling eyes
1f60d   😍        smiling face with heart-shaped eyes
1f60e   😎        smiling face with sunglasses
1f619   😙        kissing face with smiling eyes
1f638   😸        grinning cat face with smiling eyes
1f63a   😺        smiling cat face with open mouth
1f63b   😻        smiling cat face with heart-shaped eyes
1f642   🙂        slightly smiling face
1f92d   🤭        smiling face with smiling eyes and hand covering mouth
1f970   🥰        smiling face with smiling eyes and three hearts
1f972   🥲        smiling face with tear
 found 20 glyphs matching "smiling"
```

Here, the check mark indicates that the glyph is defined in
the current release of the JuliaMono font (it doesn't know
which font you're currently using in your terminal).

Glyphy can also look for the glyph with a specific integer
code point. It's usual to type them as hexadecimal integers,
so `0x2055`, `0x1f638`, etc.

```
julia> glyphy(0x1f638)

1f638   😸        grinning cat face with smiling eyes
 You can enter this glyph by typing \:smile_cat: TAB
```

There are over 30,000 characters to search, so searches
might take a few milliseconds...

The current version of Unicode is 14.0, released in 2021.
The glyph list used by Glyphy is `UnicodeData.txt` from
[here](http://www.unicode.org/Public/UNIDATA/).

Glyphy is also available as a web service, at [glyphy.info](https://glyphy.info):

![glyphy.info](docs/src/assets/figures/glyphy-info.png)

[docs-development-img]: https://img.shields.io/badge/docs-development-blue
[docs-development-url]: http://cormullion.github.io/glyphy.jl/dev/

[docs-stable-img]: https://img.shields.io/badge/docs-stable-blue.svg
[docs-stable-url]: http://cormullion.github.io/glyphy.jl/stable/

[ci-img]: https://github.com/cormullion/glyphy.jl/workflows/CI/badge.svg
[ci-url]: https://github.com/cormullion/glyphy.jl/actions?query=workflow%3ACI
