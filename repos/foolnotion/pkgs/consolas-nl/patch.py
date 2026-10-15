#!/usr/bin/env python3
"""Patch Consolas into Consolas NL with terminal-safe fallback glyphs."""

from pathlib import Path

from fontTools.ttLib import TTFont

VARIANTS = {
    "consola.ttf": "ConsolasNL-Regular.ttf",
    "consolab.ttf": "ConsolasNL-Bold.ttf",
    "consolai.ttf": "ConsolasNL-Italic.ttf",
    "consolaz.ttf": "ConsolasNL-BoldItalic.ttf",
}

# Authoritative vertical metric values for Consolas.  These are its original
# OS/2 winAscent and winDescent values, which center it correctly on Windows.
ASCENDER = 1884
DESCENDER = -514
LINE_GAP = 0


def strip_hints(font: TTFont) -> None:
    """Remove TrueType hints and enable symmetric antialiasing."""
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

    # 0x000A = DOGRAY (0x0002) | SYMMETRIC_SMOOTHING (0x0008)
    if "gasp" in font:
        font["gasp"].gaspRange = {0xFFFF: 0x000A}
    else:
        from fontTools.ttLib.tables import G_A_S_P_

        gasp = G_A_S_P_.table_G_A_S_P_()
        gasp.version = 1
        gasp.gaspRange = {0xFFFF: 0x000A}
        font["gasp"] = gasp

    # Clear flags for point-size-dependent instructions, integer ppem, and
    # instructions that alter advance widths.
    font["head"].flags &= ~0x001C


def fix_metrics(font: TTFont) -> None:
    """Use Consolas' original Windows line box in every renderer."""
    os2 = font["OS/2"]
    hhea = font["hhea"]

    os2.fsSelection |= 0x80  # USE_TYPO_METRICS
    os2.sTypoAscender = ASCENDER
    os2.sTypoDescender = DESCENDER
    os2.sTypoLineGap = LINE_GAP
    os2.usWinAscent = ASCENDER
    os2.usWinDescent = -DESCENDER

    hhea.ascent = ASCENDER
    hhea.descent = DESCENDER
    hhea.lineGap = LINE_GAP


def remove_bitmaps(font: TTFont) -> None:
    for table in ("EBLC", "EBDT", "EBSC"):
        if table in font:
            del font[table]


# Glyphs imported from dedicated monospaced donors when absent from Consolas.
# JuliaMono supplies scientific and mathematical Unicode; DejaVu Sans Mono
# remains the source for terminal diagrams and Nerd Font icon glyphs.
_MATH_IMPORT_RANGES = [
    (0x0300, 0x036F),    # Combining Diacritical Marks
    (0x2070, 0x209F),    # Superscripts and Subscripts
    (0x2100, 0x214F),    # Letterlike Symbols
    (0x2190, 0x21FF),    # Arrows
    (0x2200, 0x22FF),    # Mathematical Operators
    (0x2300, 0x23FF),    # Miscellaneous Technical
    (0x2700, 0x2BFF),    # Dingbats, supplemental arrows and operators
    (0x1D400, 0x1D7FF),  # Mathematical Alphanumeric Symbols
]

_TERMINAL_IMPORT_RANGES = [
    (0x2500, 0x257F),  # Box Drawing
    (0x2580, 0x259F),  # Block Elements
    (0x25A0, 0x26FF),  # Geometric and miscellaneous symbols
    (0xE000, 0xF8FF),  # BMP Private Use (Powerline and Nerd Font icons)
]


def target_advance_width(codepoint: int, cell_width: int) -> int:
    """Combining marks must not consume a terminal cell."""
    return 0 if 0x0300 <= codepoint <= 0x036F else cell_width


def import_terminal_glyphs(font: TTFont, source_path: str, ranges: list[tuple[int, int]]) -> None:
    """Import, flatten, and rescale missing glyphs from a TrueType donor."""
    from fontTools.pens.recordingPen import DecomposingRecordingPen
    from fontTools.pens.transformPen import TransformPen
    from fontTools.pens.ttGlyphPen import TTGlyphPen

    src = TTFont(source_path)
    src_cmap = src.getBestCmap() or {}
    src_glyph_set = src.getGlyphSet()
    src_glyf = src["glyf"]
    src_hmtx = src["hmtx"].metrics
    src_os2 = src["OS/2"]

    # getBestCmap() will prefer this Windows UCS-4 table once it exists.
    # Seed it with every existing Unicode mapping; otherwise renderers that
    # choose it can only resolve subsequently imported glyphs.
    tgt_cmap = font.getBestCmap() or {}

    if not any(table.format == 12 for table in font["cmap"].tables):
        from fontTools.ttLib.tables._c_m_a_p import CmapSubtable

        unicode_cmap = CmapSubtable.newSubtable(12)
        unicode_cmap.platformID = 3
        unicode_cmap.platEncID = 10
        unicode_cmap.language = 0
        unicode_cmap.cmap = tgt_cmap.copy()
        font["cmap"].tables.append(unicode_cmap)

    ref_src = src_cmap.get(0x41) or next(iter(src_hmtx))
    if not ref_src:
        print("  [import] donor has no reference glyph; skipping")
        return

    src_aw = src_hmtx[ref_src][0]
    src_asc = src_os2.sTypoAscender
    src_dsc = src_os2.sTypoDescender
    src_h = src_asc - src_dsc

    tgt_cmap = font.getBestCmap() or {}
    tgt_hmtx = font["hmtx"].metrics
    ref_tgt = tgt_cmap.get(0x41) or next(iter(tgt_hmtx))
    tgt_aw = tgt_hmtx[ref_tgt][0]
    tgt_h = ASCENDER - DESCENDER

    sx = tgt_aw / src_aw
    sy = tgt_h / src_h
    dy0 = DESCENDER - src_dsc * sy

    tgt_glyf = font["glyf"]
    new_names: list[str] = []

    for lo, hi in ranges:
        for codepoint in range(lo, hi + 1):
            src_name = src_cmap.get(codepoint)
            if not src_name or codepoint in tgt_cmap:
                continue

            src_glyph = src_glyf[src_name]
            if src_glyph.isComposite():
                recording_pen = DecomposingRecordingPen(src_glyph_set)
                try:
                    src_glyph_set[src_name].draw(recording_pen)
                    flattening_pen = TTGlyphPen(None)
                    recording_pen.replay(flattening_pen)
                    src_glyph = flattening_pen.glyph()
                except Exception as exc:
                    print("  [import] skip U+%04X: %s" % (codepoint, exc))
                    continue

            if not hasattr(src_glyph, "numberOfContours") or src_glyph.numberOfContours <= 0:
                continue

            pen = TTGlyphPen(None)
            transform_pen = TransformPen(pen, (sx, 0, 0, sy, 0, dy0))
            src_glyph.draw(transform_pen, src_glyf)
            new_glyph = pen.glyph()

            glyph_name = "uni%04X" % codepoint
            tgt_glyf[glyph_name] = new_glyph
            new_glyph.recalcBounds(tgt_glyf)
            tgt_hmtx[glyph_name] = (
                target_advance_width(codepoint, tgt_aw),
                new_glyph.xMin,
            )
            new_names.append(glyph_name)

            for table in font["cmap"].tables:
                if table.format == 12 or (table.format == 4 and codepoint <= 0xFFFF):
                    table.cmap[codepoint] = glyph_name

    if new_names:
        # glyf.__setitem__ appends glyph names to the shared glyph order.  Do
        # not call setGlyphOrder(), which would append them a second time.
        if hasattr(font, "_reverseGlyphOrderDict"):
            del font._reverseGlyphOrderDict
        print("  [import] %d glyphs added from %s" % (len(new_names), source_path))


def rename_family(font: TTFont) -> None:
    name_table = font["name"]
    for record in name_table.names:
        try:
            current = record.toUnicode()
        except Exception:
            continue

        if record.nameID in (1, 16):
            updated = "Consolas NL"
        elif record.nameID == 4:
            updated = current.replace("Consolas", "Consolas NL")
        elif record.nameID == 6:
            updated = current.replace("Consolas", "ConsolasNL")
        else:
            continue

        if record.platformID in (0, 3):
            record.string = updated.encode("utf-16-be")
        elif record.platformID == 1:
            try:
                record.string = updated.encode("mac_roman")
            except UnicodeEncodeError:
                record.string = updated.encode("utf-8")


def print_metrics(font: TTFont, label: str) -> None:
    os2 = font["OS/2"]
    hhea = font["hhea"]
    print(f"  [{label}]")
    print(f"    typo : asc={os2.sTypoAscender:+d}  desc={os2.sTypoDescender:+d}  gap={os2.sTypoLineGap}")
    print(f"    win  : asc={os2.usWinAscent:+d}  desc={os2.usWinDescent:+d}")
    print(f"    hhea : asc={hhea.ascent:+d}  desc={hhea.descent:+d}  gap={hhea.lineGap}")
    print(f"    USE_TYPO_METRICS: {bool(os2.fsSelection & 0x80)}")


def process(
    src: Path,
    dst: Path,
    math_source: Path | None = None,
    terminal_source: Path | None = None,
) -> None:
    print(f"\n{'-' * 60}")
    print(f"  {src.name} -> {dst.name}")
    print("-" * 60)

    font = TTFont(src)
    print_metrics(font, "before")
    strip_hints(font)
    fix_metrics(font)
    remove_bitmaps(font)
    if math_source:
        import_terminal_glyphs(font, str(math_source), _MATH_IMPORT_RANGES)
    if terminal_source:
        import_terminal_glyphs(font, str(terminal_source), _TERMINAL_IMPORT_RANGES)
    rename_family(font)
    print_metrics(font, "after")
    font.save(dst)
    print(f"  saved -> {dst}")


def main() -> None:
    import sys

    if len(sys.argv) in (3, 4, 5):
        math_source = Path(sys.argv[3]) if len(sys.argv) >= 4 else None
        terminal_source = Path(sys.argv[4]) if len(sys.argv) == 5 else None
        process(Path(sys.argv[1]), Path(sys.argv[2]), math_source, terminal_source)
        return

    work_dir = Path(__file__).parent
    out_dir = work_dir / "output"
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
