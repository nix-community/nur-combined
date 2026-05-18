#!/usr/bin/env python3
"""
Patch Consolas → Consolas NL (No-hints).

Steps applied to each variant:
  1. Strip all TrueType hints (cvt/fpgm/prep tables, per-glyph programs,
     hdmx/LTSH/VDMX metrics tables, head hint flags)
  2. Set gasp to symmetric smoothing only (no grid-fitting) for all sizes
  3. Fix vertical metrics: enable USE_TYPO_METRICS, normalise all three
     metric sets (typo / win / hhea) to the correct Windows values
  4. Remove embedded bitmap tables (EBLC / EBDT / EBSC)
  5. Import missing glyphs (Arrows, Math Operators, Misc Technical, Box
     Drawing, Block Elements, Geometric Shapes) from DejaVu Sans Mono,
     rescaled to fit the target cell geometry — Consolas lacks all of these,
     so without this step they fall back to a font with a different advance
     width, breaking alignment in diagrams and editors
  6. Rename font family to "Consolas NL" throughout the name table

Output files are written to ./output/.
"""

from pathlib import Path
from fontTools.ttLib import TTFont

VARIANTS = {
    "consola.ttf":  "ConsolasNL-Regular.ttf",
    "consolab.ttf": "ConsolasNL-Bold.ttf",
    "consolai.ttf": "ConsolasNL-Italic.ttf",
    "consolaz.ttf": "ConsolasNL-BoldItalic.ttf",
}

# Authoritative vertical metric values for Consolas.
# Source: OS/2 winAscent / winDescent from the original font, which
# produce the correct visual centering on Windows.
ASCENDER  =  1884
DESCENDER = -514
LINE_GAP  =  0


# ── 1. Hint stripping ──────────────────────────────────────────────────────────

def strip_hints(font: TTFont) -> None:
    from fontTools.ttLib.tables.ttProgram import Program

    for table in ("cvt ", "fpgm", "prep", "hdmx", "LTSH", "VDMX", "cvar"):
        if table in font:
            del font[table]

    if "glyf" in font:
        empty = Program()
        empty.fromAssembly([])
        glyf_table = font["glyf"]
        for glyph_name in font.getGlyphOrder():
            glyph = glyf_table[glyph_name]
            if hasattr(glyph, "program") and glyph.program is not None:
                glyph.program = empty

    # Update gasp: symmetric smoothing for all ppem, no grid-fitting.
    # 0x000A = DOGRAY (0x0002) | SYMMETRIC_SMOOTHING (0x0008)
    if "gasp" in font:
        font["gasp"].gaspRange = {0xFFFF: 0x000A}
    else:
        from fontTools.ttLib.tables import G_A_S_P_
        gasp = G_A_S_P_.table_G_A_S_P_()
        gasp.version = 1
        gasp.gaspRange = {0xFFFF: 0x000A}
        font["gasp"] = gasp

    # Clear head flags: bits 2 (instructions depend on point size),
    # 3 (force integer ppem), 4 (instructions alter advance widths).
    font["head"].flags &= ~0x001C


# ── 2. Vertical metrics ────────────────────────────────────────────────────────

def fix_metrics(font: TTFont) -> None:
    os2  = font["OS/2"]
    hhea = font["hhea"]

    # Enable USE_TYPO_METRICS so all renderers agree on the line box.
    os2.fsSelection |= 0x80

    os2.sTypoAscender  = ASCENDER
    os2.sTypoDescender = DESCENDER
    os2.sTypoLineGap   = LINE_GAP
    os2.usWinAscent  = ASCENDER
    os2.usWinDescent = -DESCENDER  # unsigned in the spec

    hhea.ascent   = ASCENDER
    hhea.descent  = DESCENDER
    hhea.lineGap  = LINE_GAP


# ── 3. Bitmap removal ──────────────────────────────────────────────────────────

def remove_bitmaps(font: TTFont) -> None:
    for table in ("EBLC", "EBDT", "EBSC"):
        if table in font:
            del font[table]


# ── 4. Box-drawing import ─────────────────────────────────────────────────────
#
# Consolas does not include box-drawing or block-element characters; VS Code
# falls back to the system font for them, and that font's advance width does
# not match Consolas NL's cell width, causing misalignment.
#
# Fix: copy all 128 Box Drawing (U+2500–U+257F) and 32 Block Element
# (U+2580–U+259F) glyphs from DejaVu Sans Mono and rescale them to fit
# Consolas NL's exact cell geometry.
#
# Affine transform mapping source cell → target cell:
#   x′ = x · (tgt_aw / src_aw)
#   y′ = y · (tgt_h / src_h)  +  (DESCENDER − src_descender · tgt_h/src_h)
# Maps src_descender→DESCENDER and src_ascender→ASCENDER, so every feature
# (midpoints, proportions, connections) is preserved within the cell.

# All ranges that Consolas lacks.
_IMPORT_RANGES = [
    (0x2190, 0x21FF),  # Arrows              (→ ↓ ← ↑ ⇒ …)
    (0x2200, 0x22FF),  # Math Operators      (∀ ∈ ≤ …)
    (0x2300, 0x23FF),  # Misc Technical      (⌘ ⌥ …)
    (0x2500, 0x257F),  # Box Drawing         (─ │ ┌ …)
    (0x2580, 0x259F),  # Block Elements      (█ ▌ …)
    (0x25A0, 0x25FF),  # Geometric Shapes    (■ ▲ ► ▼ ◄ …)
    (0x2600, 0x26FF),  # Misc Symbols        (☀ ✓ ✗ ⚡ …)
    (0xE000, 0xF8FF),  # BMP Private Use     (Powerline, NF icons, Font Awesome …)
]


def import_box_drawing(font: TTFont, source_path: str) -> None:
    """Import and rescale box-drawing glyphs from source_path into font."""
    from fontTools.pens.ttGlyphPen import TTGlyphPen
    from fontTools.pens.transformPen import TransformPen

    src      = TTFont(source_path)
    src_cmap = src.getBestCmap() or {}
    src_glyf = src["glyf"]
    src_hmtx = src["hmtx"].metrics
    src_os2  = src["OS/2"]

    ref_src = src_cmap.get(0x2500)
    if not ref_src:
        print("  [box drawing] source has no U+2500, skipping import")
        return
    src_aw  = src_hmtx[ref_src][0]
    src_asc = src_os2.sTypoAscender
    src_dsc = src_os2.sTypoDescender
    src_h   = src_asc - src_dsc

    tgt_cmap = font.getBestCmap() or {}
    tgt_hmtx = font["hmtx"].metrics
    ref_tgt  = tgt_cmap.get(0x41) or next(iter(tgt_hmtx))
    tgt_aw   = tgt_hmtx[ref_tgt][0]
    tgt_h    = ASCENDER - DESCENDER

    sx  = tgt_aw / src_aw
    sy  = tgt_h  / src_h
    dy0 = DESCENDER - src_dsc * sy

    tgt_glyf  = font["glyf"]
    new_names: list = []

    for lo, hi in _IMPORT_RANGES:
        for cp in range(lo, hi + 1):
            src_name = src_cmap.get(cp)
            if not src_name or cp in tgt_cmap:
                continue

            src_glyph = src_glyf[src_name]

            if src_glyph.isComposite():
                pen_inner = TTGlyphPen(None)
                try:
                    src_glyph.draw(pen_inner, src_glyf)
                    src_glyph = pen_inner.glyph()
                except Exception as exc:
                    print("  [import] skip U+%04X: %s" % (cp, exc))
                    continue

            if not hasattr(src_glyph, "numberOfContours") or src_glyph.numberOfContours <= 0:
                continue

            pen   = TTGlyphPen(None)
            t_pen = TransformPen(pen, (sx, 0, 0, sy, 0, dy0))
            src_glyph.draw(t_pen, src_glyf)
            new_glyph = pen.glyph()

            tgt_name = "uni%04X" % cp
            tgt_glyf[tgt_name] = new_glyph
            new_glyph.recalcBounds(tgt_glyf)
            tgt_hmtx[tgt_name] = (tgt_aw, new_glyph.xMin)
            new_names.append(tgt_name)

            for table in font["cmap"].tables:
                if table.format in (4, 12):
                    table.cmap[cp] = tgt_name

    if new_names:
        # glyf.__setitem__ already appended each name to the shared
        # font.glyphOrder / glyf.glyphOrder list object (see _g_l_y_f.py:104).
        # Calling font.setGlyphOrder() would double-add them; just bust the cache.
        if hasattr(font, "_reverseGlyphOrderDict"):
            del font._reverseGlyphOrderDict
        print("  [import] %d glyphs added from %s" % (len(new_names), source_path))


# ── 5. Family rename ───────────────────────────────────────────────────────────

def rename_family(font: TTFont) -> None:
    name_table = font["name"]
    for record in name_table.names:
        try:
            current = record.toUnicode()
        except Exception:
            continue

        if record.nameID in (1, 16):          # Family / Preferred Family
            updated = "Consolas NL"
        elif record.nameID == 4:              # Full name
            updated = current.replace("Consolas", "Consolas NL")
        elif record.nameID == 6:              # PostScript name
            updated = current.replace("Consolas", "ConsolasNL")
        else:
            continue

        if record.platformID in (0, 3):        # Unicode / Windows: UTF-16 BE
            record.string = updated.encode("utf-16-be")
        elif record.platformID == 1:          # Mac: MacRoman
            try:
                record.string = updated.encode("mac_roman")
            except UnicodeEncodeError:
                record.string = updated.encode("utf-8")


# ── Diagnostic helper ──────────────────────────────────────────────────────────

def print_metrics(font: TTFont, label: str) -> None:
    os2  = font["OS/2"]
    hhea = font["hhea"]
    print(f"  [{label}]")
    print(f"    typo : asc={os2.sTypoAscender:+d}  desc={os2.sTypoDescender:+d}  gap={os2.sTypoLineGap}")
    print(f"    win  : asc={os2.usWinAscent:+d}  desc={os2.usWinDescent:+d}")
    print(f"    hhea : asc={hhea.ascent:+d}  desc={hhea.descent:+d}  gap={hhea.lineGap}")
    print(f"    USE_TYPO_METRICS: {bool(os2.fsSelection & 0x80)}")


# ── Main ───────────────────────────────────────────────────────────────────────

def process(src: Path, dst: Path, box_source: Path | None = None) -> None:
    print(f"\n{'─'*60}")
    print(f"  {src.name} → {dst.name}")
    print(f"{'─'*60}")

    font = TTFont(src)
    print_metrics(font, "before")

    strip_hints(font)
    fix_metrics(font)
    remove_bitmaps(font)
    if box_source:
        import_box_drawing(font, str(box_source))
    rename_family(font)

    print_metrics(font, "after")
    font.save(dst)
    print(f"  saved → {dst}")


def main() -> None:
    import sys

    if len(sys.argv) in (3, 4):
        # Single-file mode: patch.py <src.ttf> <dst.ttf> [<box-source.ttf>]
        box_src = Path(sys.argv[3]) if len(sys.argv) == 4 else None
        process(Path(sys.argv[1]), Path(sys.argv[2]), box_src)
    else:
        # Batch mode: process all four variants from the working directory
        work_dir = Path(__file__).parent
        out_dir  = work_dir / "output"
        out_dir.mkdir(exist_ok=True)

        for src_name, dst_name in VARIANTS.items():
            src = work_dir / src_name
            if not src.exists():
                print(f"  WARNING: {src} not found, skipping")
                continue
            process(src, out_dir / dst_name)

        print(f"\nAll done. Fonts written to {out_dir}")


if __name__ == "__main__":
    main()
