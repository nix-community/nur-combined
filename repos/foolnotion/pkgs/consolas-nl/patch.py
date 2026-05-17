#!/usr/bin/env python3
"""
Patch Consolas → Consolas NL (No-hints Linux).

Steps applied to each variant:
  1. Strip all TrueType hints (cvt/fpgm/prep tables, per-glyph programs,
     hdmx/LTSH/VDMX metrics tables, head hint flags)
  2. Set gasp to symmetric smoothing only (no grid-fitting) for all sizes
  3. Fix vertical metrics: enable USE_TYPO_METRICS, normalise all three
     metric sets (typo / win / hhea) to the correct Windows values
  4. Remove embedded bitmap tables (EBLC / EBDT / EBSC)
  5. Rename font family to "Consolas NL" throughout the name table

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
    # 0x0002 = DOGRAY, 0x0008 = SYMMETRIC_SMOOTHING
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


# ── 4. Family rename ───────────────────────────────────────────────────────────

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

        if record.platformID == 3:            # Windows: UTF-16 BE
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

def process(src: Path, dst: Path) -> None:
    print(f"\n{'─'*60}")
    print(f"  {src.name} → {dst.name}")
    print(f"{'─'*60}")

    font = TTFont(src)
    print_metrics(font, "before")

    strip_hints(font)
    fix_metrics(font)
    remove_bitmaps(font)
    rename_family(font)

    print_metrics(font, "after")
    font.save(dst)
    print(f"  saved → {dst}")


def main() -> None:
    import sys

    if len(sys.argv) == 3:
        # Single-file mode: patch.py <src.ttf> <dst.ttf>
        process(Path(sys.argv[1]), Path(sys.argv[2]))
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
