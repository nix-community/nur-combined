import argparse
import shutil
from copy import deepcopy
from pathlib import Path

from fontTools.ttLib import TTFont  # ty: ignore[unresolved-import]
from fontTools.ttLib.tables.ttProgram import Program  # ty: ignore[unresolved-import]

CODEPOINTS = (0x25A0, 0x25A1, 0x25E7)  # ■ □ ◧
CHANGED_TABLES = {"GlyphOrder", "glyf", "loca", "hmtx", "hhea", "head", "maxp", "post"}


def shared_outlines(font):
    names = {font.getBestCmap()[codepoint] for codepoint in CODEPOINTS}
    return {
        component.glyphName: component.glyphName + ".meter-original"
        for name in font.getGlyphOrder()
        for glyph in [font["glyf"][name]]
        if glyph.isComposite()
        for component in glyph.components
        if component.glyphName in names
    }


def connect(font):
    # Other symbols, such as the ballot box, reuse the white-square outline.
    originals = shared_outlines(font)
    for name, preserved in originals.items():
        font["glyf"][preserved] = deepcopy(font["glyf"][name])
        font["hmtx"][preserved] = font["hmtx"][name]
    for name in font.getGlyphOrder():
        glyph = font["glyf"][name]
        if glyph.isComposite():
            for component in glyph.components:
                component.glyphName = originals.get(
                    component.glyphName, component.glyphName
                )
    for codepoint in CODEPOINTS:
        connect_glyph(font, font.getBestCmap()[codepoint])


def connect_glyph(font, name):
    glyph = font["glyf"][name]
    assert not glyph.isComposite(), "Expected a simple meter-square outline"
    glyph.recalcBounds(font["glyf"])
    left, right = glyph.xMin, glyph.xMax
    advance, _ = font["hmtx"][name]
    assert right > left and advance > 0, "Invalid meter-square dimensions"
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
            assert modified.getBestCmap() == original.getBestCmap(), path
            originals = shared_outlines(original)
            assert modified.getGlyphOrder() == original.getGlyphOrder() + list(
                originals.values()
            ), path
            for name, preserved in originals.items():
                assert modified["hmtx"][preserved] == original["hmtx"][name], (
                    path,
                    name,
                )
                assert modified["glyf"][preserved].compile(
                    modified["glyf"]
                ) == original["glyf"][name].compile(original["glyf"]), (path, name)
            names = {original.getBestCmap()[codepoint] for codepoint in CODEPOINTS}
            for name in names:
                before = original["glyf"][name]
                after = modified["glyf"][name]
                before.recalcBounds(original["glyf"])
                after.recalcBounds(modified["glyf"])
                advance = original["hmtx"][name][0]
                assert modified["hmtx"][name] == (advance, 0), (path, name)
                assert (after.xMin, after.xMax) == (0, advance), (path, name)
                assert (after.yMin, after.yMax) == (before.yMin, before.yMax), (
                    path,
                    name,
                )
                assert list(after.coordinates) == [
                    (
                        round(
                            (x - before.xMin) * advance / (before.xMax - before.xMin)
                        ),
                        y,
                    )
                    for x, y in before.coordinates
                ], (path, name)
                assert after.endPtsOfContours == before.endPtsOfContours, (path, name)
                assert after.flags == before.flags, (path, name)
                assert not after.program.getBytecode(), (path, name)
            for glyph_name in original.getGlyphOrder():
                if glyph_name not in names:
                    assert (
                        modified["hmtx"][glyph_name] == original["hmtx"][glyph_name]
                    ), (path, glyph_name)
                    glyph = deepcopy(modified["glyf"][glyph_name])
                    if glyph.isComposite():
                        restored = {value: key for key, value in originals.items()}
                        for component in glyph.components:
                            component.glyphName = restored.get(
                                component.glyphName, component.glyphName
                            )
                    assert glyph.compile(original["glyf"]) == original["glyf"][
                        glyph_name
                    ].compile(original["glyf"]), (
                        path,
                        glyph_name,
                    )
            # The post table gains a glyph name; its metrics must remain unchanged.
            assert (
                modified.getTableData("post")[:32] == original.getTableData("post")[:32]
            ), path
            for tag in original.keys():  # noqa: SIM118
                if tag not in CHANGED_TABLES:
                    assert modified.getTableData(tag) == original.getTableData(tag), (
                        path,
                        tag,
                    )
    print(
        f"Verified {len(originals)} fonts: U+25A0, U+25A1 and U+25E7 span one cell; vertical bounds, other glyphs and layout tables preserved"
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
