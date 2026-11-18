# ElyOffice

Offline office suite (Rust + GPUI) from
[ELY-Open-Source/ElyOffice](https://github.com/ELY-Open-Source/ElyOffice).

## What is built from source

- All seven apps (`ely-doc`, `ely-table`, `ely-show`, `ely-pdf`, `ely-mail`,
  `ely-tree`, `ely-mark`) and both workers (`ely-lok-worker`,
  `ely-pdf-worker`), from the `v0.1.16` tag with `Cargo.lock` vendored by
  `rustPlatform`.
- MuPDF 1.28.5 with the upstream patch series (`./patches`, copied from
  `patches/mupdf` upstream). The PDF worker links its static archives, a static
  OpenSSL and its bundled Tesseract/Leptonica.
- The OCR language data (`tessdata_fast` at the commit
  `scripts/fetch-tessdata.sh` pins).

Git and git-lfs come from nixpkgs and are linked into `bin/git/`, where the
apps look for the copy ElyTree normally carries.

## LibreOffice kernel

ElyDoc, ElyTable and ElyShow drive a patched LibreOffice 26.2.6.3 LOK kernel
(139 patches, `--enable-mergelibs`, bundled dependencies). Upstream builds it
in an AlmaLinux 8 container; reproducing that in a Nix sandbox is an
hours-long, tens-of-gigabyte build, so the kernel from the matching `v0.1.16`
release is unpacked instead:

- `x86_64-linux`: the Arch package `ely-doc-0.1.16-1-x86_64.pkg.tar.zst`
  (`opt/ely-office/ely-doc/bin/libreoffice`).
- `aarch64-darwin`: `ElyDoc-0.1.16-arm64.dmg`, kept in LibreOffice's bundle
  layout as `Contents/Frameworks` and `Contents/Resources` (LibreOffice reads
  its `unorc`/`sofficerc` from `Resources` relative to `Frameworks`).

`packaging/lean.sh` upstream trims the kernel for releases; the released
kernel is used as shipped. The kernel is installed under
`$out/lib/elyoffice/libreoffice` and linked from `$out/bin/libreoffice`; the
three office apps' wrappers also set `ELY_LOK_DIR` to the platform's kernel
directory (`program` on Linux, `Contents/Frameworks` on macOS).

## Platforms

`x86_64-linux` and `aarch64-darwin`, matching the releases that carry a
kernel. Other systems would build the apps but the three office apps would
have no engine.
