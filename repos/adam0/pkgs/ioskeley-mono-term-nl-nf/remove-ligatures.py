import argparse
import shutil
from pathlib import Path

from fontTools import subset  # ty: ignore[unresolved-import]
from fontTools.ttLib import TTFont  # ty: ignore[unresolved-import]

LIGATURE_FEATURES = {"calt", "clig", "dlig", "liga", "rlig"}
NAME_IDS = {1, 3, 4, 6, 16, 18, 21, 25}


def features(font):
    if "GSUB" not in font:
        return set()
    return {
        record.FeatureTag for record in font["GSUB"].table.FeatureList.FeatureRecord
    }


def convert(source, destination, family_name, spaced_family_name):
    shutil.copytree(
        source, destination, dirs_exist_ok=True, copy_function=shutil.copyfile
    )
    for path in sorted(destination.rglob("*.ttf")):
        with TTFont(path, recalcTimestamp=False) as font:
            options = subset.Options()
            options.layout_features = sorted(features(font) - LIGATURE_FEATURES)
            options.layout_scripts = ["*"]
            font["GSUB"].prune_pre_subset(font, options)
            for record in font["name"].names:
                if record.nameID in NAME_IDS:
                    value = record.toUnicode().replace(family_name, family_name + "NL")
                    value = value.replace(
                        spaced_family_name, spaced_family_name + " NL"
                    )
                    record.string = value.encode(record.getEncoding())
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
            assert not features(modified) & LIGATURE_FEATURES, path
            assert features(modified) == features(original) - LIGATURE_FEATURES, path
            assert modified.getBestCmap() == original.getBestCmap(), path
            assert modified.getGlyphOrder() == original.getGlyphOrder(), path
            for tag in original.keys():  # noqa: SIM118
                if tag not in {"GlyphOrder", "GSUB", "name", "head"}:
                    assert modified.getTableData(tag) == original.getTableData(tag), (
                        path,
                        tag,
                    )
            for record in modified["name"].names:
                if record.nameID in {1, 16}:
                    assert (
                        "TermNL" in record.toUnicode()
                        or "Term NL" in record.toUnicode()
                    ), path
    print(
        f"Verified {len(originals)} fonts: no ligature features; glyphs, metrics, and other tables preserved"
    )


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    parser.add_argument("--family-name", default="IoskeleyMonoTerm")
    parser.add_argument("--spaced-family-name", default="Ioskeley Mono Term")
    parser.add_argument("source", type=Path)
    parser.add_argument("destination", type=Path)
    args = parser.parse_args()
    if args.check:
        check(args.source, args.destination)
    else:
        convert(
            args.source, args.destination, args.family_name, args.spaced_family_name
        )
