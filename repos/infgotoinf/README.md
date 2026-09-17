# -inf's NUR packages

**My personal [NUR](https://github.com/nix-community/NUR) repository**

![Build and populate cache](https://github.com/infgotoinf/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)

[![Cachix Cache](https://img.shields.io/badge/cachix-infgotoinf-blue.svg)](https://infgotoinf.cachix.org)

## Packages

### unifont-psf

A specialized PSF 1 console frame buffer font consisting of 512 glyphs for use with APL, A Programming Language, in console mode (single-user mode on GNU/Linux, etc.), mainly to support GNU APL. Can be found [here](https://unifoundry.com/unifont/index.html).
Add fonts:
- `Unifont-pfs`

### UnifontExMono

An extended fork of GNU Unifont with a focus on high compatibility. Can be found [here](https://github.com/stgiga/UnifontEX).
Add fonts:
- `UnifontExMono`

### retrosmart-x11-cursors

An old-fashioned look X11 cursor theme. Can be found [here](https://github.com/mdomlop/retrosmart-x11-cursors).
Add cursors:
- `retrosmart-xcursor-black`
- `retrosmart-xcursor-black-color`
- `retrosmart-xcursor-black-color-shadow`
- `retrosmart-xcursor-black-shadow`
- `retrosmart-xcursor-white`
- `retrosmart-xcursor-white-color`
- `retrosmart-xcursor-white-color-shadow`
- `retrosmart-xcursor-white-shadow`

### zaread

A (very) lightweight MS Office file reader. Can be found [here](https://github.com/paoloap/zaread/tree/master)

Add applications:
- `zaread`

#### What file formats does zaread support?

- PDF, DJVU, EPUB (opened directly via zathura)
- OOXML documents (docx, xlsx, pptx, and macro-enabled variants like xlsm, docm, pptm)
- Old MS Office documents (doc, xls, ppt)
- OpenDocument formats (odt, ods, odp)
- Other Office formats (xlsb, ppsx, dotx)
- MOBI
- CSV, RTF
- Markdown (md)
- Typst (typ)

#### What about optional dependences?

- **pkgs.libreoffice** (`soffice`) -- for Office documents, CSV, and RTF. Unfortunately there's no lighter alternative for converting Office files on Linux.
- **pkgs.calibre** (`ebook-convert`) -- for MOBI. Same story.
- **pkgs.md2pdf** -- for Markdown. Has some Python dependencies but it's a better option than the old pandoc approach, which needed the whole texlive suite.
- **pkgs.typst** -- for Typst documents.

#### Can I use a different PDF viewer?

Yes. Create a config file at `~/.config/zaread/zareadrc` (or `$XDG_CONFIG_HOME/zaread/zareadrc`) and override any of the default variables:

```sh
# Reader
READER="zathura"
READER_ARG=""

# Converters
OFFICE_CMD="soffice"       # LibreOffice
OFFICE_ARG=""
MOBI_CMD="ebook-convert"   # calibre
MOBI_ARG=""
MD_CMD="md2pdf"
MD_ARG=""
TYPST_CMD="typst"
TYPST_ARG="compile"

# Behavior
VERBOSE=0
```

The config is sourced as shell, so anything you set there takes effect at runtime.
