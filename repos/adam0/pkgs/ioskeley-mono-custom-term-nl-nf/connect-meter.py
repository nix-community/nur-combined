import argparse
import shutil
from pathlib import Path

from fontTools.ttLib import TTFont  # ty: ignore[unresolved-import]
from fontTools.ttLib.tables.ttProgram import Program  # ty: ignore[unresolved-import]

CODEPOINT = 0x25A0
CHANGED_TABLES = {"GlyphOrder", "glyf", "loca", "hmtx", "hhea", "head", "maxp"}


def connect(font):
    name = font.getBestCmap()[CODEPOINT]
    glyph = font["glyf"][name]
    assert not glyph.isComposite(), "Expected a simple black-square outline"
    glyph.recalcBounds(font["glyf"])
    left, right = glyph.xMin, glyph.xMax
    advance, _ = font["hmtx"][name]
    assert right > left and advance > 0, "Invalid black-square dimensions"
    for index, (x, y) in enumerate(glyph.coordinates):
        glyph.coordinates[index] = (round((x - left) * advance / (right - left)), y)
    glyph.program = Program()
    glyph.program.fromBytecode([])
    glyph.recalcBounds(font["glyf"])
    font["hmtx"][name] = (advance, 0)


def convert(source, destination):
    shutil.copytree(
        source, destination, dirs_exist_ok=True, copy_function=shutil.copyfile
    )
    paths = sorted(destination.rglob("*.ttf"))
    assert paths, "No source fonts found"
    for path in paths:
        with TTFont(path, recalcTimestamp=False) as font:
            connect(font)
            font.save(path)


def check(source, destination):
    originals = sorted(source.rglob("*.ttf"))
    assert originals, "No source fonts found"
    assert len(originals) == len(list(destination.rglob("*.ttf")))
    for path in originals:
        with (
            TTFont(path) as original,
            TTFont(destination / path.relative_to(source)) as modified,
        ):
            name = original.getBestCmap()[CODEPOINT]
            assert modified.getBestCmap() == original.getBestCmap(), path
            assert modified.getGlyphOrder() == original.getGlyphOrder(), path
            before = original["glyf"][name]
            after = modified["glyf"][name]
            before.recalcBounds(original["glyf"])
            after.recalcBounds(modified["glyf"])
            advance = original["hmtx"][name][0]
            assert modified["hmtx"][name] == (advance, 0), path
            assert (after.xMin, after.xMax) == (0, advance), path
            assert (after.yMin, after.yMax) == (before.yMin, before.yMax), path
            assert not after.program.getBytecode(), path
            for glyph_name in original.getGlyphOrder():
                if glyph_name != name:
                    assert (
                        modified["hmtx"][glyph_name] == original["hmtx"][glyph_name]
                    ), (path, glyph_name)
                    assert modified["glyf"][glyph_name].compile(
                        modified["glyf"]
                    ) == original["glyf"][glyph_name].compile(original["glyf"]), (
                        path,
                        glyph_name,
                    )
            for tag in original.keys():  # noqa: SIM118
                if tag not in CHANGED_TABLES:
                    assert modified.getTableData(tag) == original.getTableData(tag), (
                        path,
                        tag,
                    )
    print(
        f"Verified {len(originals)} fonts: U+25A0 spans one cell; vertical bounds, other glyphs and layout tables preserved"
    )


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    parser.add_argument("source", type=Path)
    parser.add_argument("destination", type=Path)
    args = parser.parse_args()
    if args.check:
        check(args.source, args.destination)
    else:
        convert(args.source, args.destination)
