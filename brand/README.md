# Snippeter brand

The Snippeter mark is the **"prompt" concept**: a terminal prompt chevron `>`
followed by a green block caret — *a snippet, ready to paste* — set on a dark
machined tile. Wordmark is **Space Grotesk** 600.

Everything is generated from the master SVGs in this folder. **Never hand-edit a
generated PNG/ICO** — edit the SVG and re-run the build.

```bash
bash brand/build.sh        # regenerate every platform asset
```

Requires `rsvg-convert` (librsvg) and `node`. The wordmark font (Space Grotesk,
vendored in `brand/fonts/`) is wired through a local fontconfig by the script.

## Palette

| Token            | Hex        | Use                                            |
| ---------------- | ---------- | ---------------------------------------------- |
| Brand green      | `#65EA92`  | caret / accent / glow on dark (`oklch .84`)    |
| Green light      | `#7CF5A2`  | caret gradient top (`oklch .88`)               |
| Green deep       | `#5EE38B`  | caret gradient bottom (`oklch .82`)            |
| Green on-light   | `#259F56`  | caret/accent on light surfaces (`oklch .62`)   |
| Tile top         | `#1C1F27`  | tile gradient 155° start                       |
| Tile bottom      | `#111319`  | tile gradient 155° end                         |
| Deep bg          | `#0D0E11`  | canvas behind the mark                         |
| Ring             | `#24272F`  | inset hairline on the tile                     |
| Ink              | `#EDEEF2`  | chevron / wordmark on dark                     |
| Ink dark         | `#16181D`  | chevron / wordmark on light                    |

## Master SVGs

| File                  | What                                                        |
| --------------------- | ----------------------------------------------------------- |
| `icon.svg`            | rounded tile (favicons, web, macOS, Android-legacy, IDEs)   |
| `icon-fullbleed.svg`  | opaque square, no radius (iOS, Windows — OS masks it)       |
| `icon-maskable.svg`   | full-bleed, glyph in safe zone (PWA maskable)               |
| `icon-foreground.svg` | glyph only, transparent (Android adaptive foreground)       |
| `icon-background.svg` | tile only (Android adaptive background)                     |
| `icon-macos.svg`      | rounded tile with the macOS ~10% margin                     |
| `glyph-dark/-light/-mono.svg` | mark only, for inline placement                     |
| `lockup-dark/-light.svg` | icon + wordmark                                          |
| `og.svg`              | 1200×630 social / OpenGraph card                            |

## Where it ships

Generated into: `web/favicon.png` + `web/icons/*`, `android/.../mipmap-*`
(legacy + adaptive `mipmap-anydpi-v26`), `ios/.../AppIcon.appiconset/*`,
`macos/.../AppIcon.appiconset/*`, `windows/runner/resources/app_icon.ico`,
`linux/snippeter.png`, `integrations/chrome/icons/*`, `integrations/vscode/icon.png`,
`integrations/jetbrains/.../META-INF/pluginIcon*.svg`,
`landing/app/{icon.svg,apple-icon.png,opengraph-image.png,twitter-image.png}`.

The in-app Flutter mark is drawn vectorially (no PNG) by `SnippeterMark`
(`lib/core/brand/`). Landing draws it inline via `components/LogoMark.tsx`.
Keep those two code-drawn marks in sync with `glyph-dark.svg`.
