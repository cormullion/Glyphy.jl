[![][gh-actions-img]][gh-actions-url]

![glyphy splash image](docs/src/assets/figures/glyphy-social-media-preview.png)

# Glyphy

Glyphy is a small utility package that searches through the names of glyphs in the Unicode
glyph list and returns a list of the glyph names that match the search term.

```julia-term
using Glyphy
julia> glyphy("peacock")

1f99a   🦚       peacock
 found one glyph matching "peacock"
```

There might be a few:

```julia-term
julia> glyphy("smiling")

0263a   ☺   ✓    white smiling face
0263b   ☻   ✓    black smiling face
1f601   😁       grinning face with smiling eyes
1f603   😃       smiling face with open mouth
1f604   😄       smiling face with open mouth and smiling eyes
1f605   😅       smiling face with open mouth and cold sweat
1f606   😆       smiling face with open mouth and tightly-closed eyes
1f607   😇       smiling face with halo
1f608   😈       smiling face with horns
1f60a   😊       smiling face with smiling eyes
1f60d   😍       smiling face with heart-shaped eyes
1f60e   😎       smiling face with sunglasses
1f619   😙       kissing face with smiling eyes
1f638   😸       grinning cat face with smiling eyes
1f63a   😺       smiling cat face with open mouth
1f63b   😻       smiling cat face with heart-shaped eyes
1f642   🙂       slightly smiling face
1f92d   🤭       smiling face with smiling eyes and hand covering mouth
1f970   🥰       smiling face with smiling eyes and three hearts
1f972   🥲       smiling face with tear
 found 20 glyphs matching "smiling"
```

Here, the check mark indicates that the glyph is defined in
the current release of the JuliaMono font (it doesn't know
which font you're currently using in your terminal).

Glyphy can also look for the glyph with a specific integer
code point. It's usual to type them as hexadecimal integers,
so `0x2055`, `0x1f638`, etc.

```julia-term
julia> glyphy(0x1f638)

1f638   😸        grinning cat face with smiling eyes
 You can enter this glyph by typing \:smile_cat: TAB
```

You can look for ranges and arrays of values:

```julia-term
julia-1.9> glyphy(0x32:0x7f)

00032   2   ✓    digit two
00033   3   ✓    digit three
00034   4   ✓    digit four
00035   5   ✓    digit five
00036   6   ✓    digit six
00037   7   ✓    digit seven
00038   8   ✓    digit eight
00039   9   ✓    digit nine
...
0007b   {   ✓    left curly bracket
0007c   |   ✓    vertical line
0007d   }   ✓    right curly bracket
0007e   ~   ✓    tilde
```

```julia-term
julia-1.9> glyphy([0x63, 0x2020, 0x2640])

00063   c   ✓    latin small letter c
02020   †   ✓    dagger
02640   ♀   ✓    female sign
```

```julia-term
julia-1.9> glyphy("^z.*")

0200b   ​         zero width space
0200c   ‌         zero width non-joiner
0200d   ‍         zero width joiner
022ff   ⋿   ✓    z notation bag membership
02981   ⦁   ✓    z notation spot
02982   ⦂   ✓    z notation type colon
...
```

There are over 30,000 characters to search, so searches
might take a few milliseconds...

### Sources

The current version of Unicode is 15.0, released in 2022.
The glyph list used by Glyphy is the file `UnicodeData.txt` from
[here](http://www.unicode.org/Public/UNIDATA/), dated 2022-08-03 17:00.

Glyphy is also available as a web service, at [glyphy.info](https://glyphy.info):

![glyphy.info](docs/src/assets/figures/glyphy-info.png)

[gh-actions-img]: https://github.com/cormullion/Glyphy.jl/workflows/CI/badge.svg
[gh-actions-url]: https://github.com/cormullion/Glyphy.jl/actions?query=workflow%3ACI