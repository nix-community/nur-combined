#!/usr/bin/env python3
"""Offline generator for browser/fonts/bundle-fonts.list.

Reads every bundled font file (.ttf / .ttc) under browser/fonts/ with
fontTools, expands .ttc collections into their individual faces, groups the
faces into families the same way the canonical Windows-11 font list does, and
emits a line-based manifest consumed at runtime by the (later, C++) uniform
font list builder. No OS font enumeration is involved - everything here is
derived straight from the font files themselves.

Manifest format (pipe-delimited, one record per line, ASCII, LF-terminated) -
chosen so the C++ reader is a trivial getline + split, safe at font-list-init:
  # <comment header>
  F|<family name>
  f|<file>|<index>|<w_min>|<w_max>|<stretch_min>|<stretch_max>|<style>|<psname>
An `f` record belongs to the most recent `F` family. Family/PostScript names
never contain `|`, so the split is unambiguous.

Usage: python gen_bundle_font_manifest.py
Writes: browser/fonts/bundle-fonts.list
"""

from __future__ import annotations

import os

from fontTools.ttLib import TTCollection, TTFont

# OS/2 usWidthClass (1-9) -> CSS font-stretch percentage.
WIDTH_CLASS_TO_PERCENT = {
    1: 50.0,
    2: 62.5,
    3: 75.0,
    4: 87.5,
    5: 100.0,
    6: 112.5,
    7: 125.0,
    8: 150.0,
    9: 200.0,
}

# Standard OpenType OS/2.usWeightClass names (the spec's own weight-class
# table). Used only to recognize a compound family name (nameID 1) that
# encodes its weight as a trailing word - e.g. "Franklin Gothic Medium" - so a
# WWS base family ("Franklin Gothic") can be derived for a face whose file
# carries no typographic-family (nameID 16) or WWS-family (nameID 21) record
# of its own.
WEIGHT_WORD_TO_CLASS = {
    "Thin": 100,
    "ExtraLight": 200,
    "UltraLight": 200,
    "Light": 300,
    "Medium": 500,
    "SemiBold": 600,
    "DemiBold": 600,
    "Demi": 600,
    "Bold": 700,
    "ExtraBold": 800,
    "UltraBold": 800,
    "Black": 900,
    "Heavy": 900,
}

# Legacy GDI-era compound family names that predate the WWS/typographic-family
# model. These files also carry a typographic-family (nameID 16) record
# pointing at a shorter base (e.g. "Arial Black" -> nameID16 "Arial"), but the
# classic/CSS-visible Windows font list keeps the compound name as its own
# family rather than folding it into that base - unlike e.g. "Segoe UI Light"
# (nameID16 "Segoe UI"), which the real font list DOES fold into "Segoe UI".
KEEP_GDI_NAME = {"Arial Black"}

# nameIDs that carry copyright / trademark / manufacturer / license text -
# every genuine Windows-supplied font attributes itself to Microsoft in at
# least one of these (even third-party-designed ones, e.g. Lucida's copyright
# is Bigelow & Holmes but its license text says "Microsoft supplied font").
# Used to exclude non-Windows fonts Firefox bundles for its own purposes (e.g.
# the Mozilla-authored Twemoji Mozilla fallback emoji font), which carry none
# of this attribution at all.
_ATTRIBUTION_NAME_IDS = (0, 7, 8, 9, 13, 14)


def _is_microsoft_supplied(name_table) -> bool:
    for name_id in _ATTRIBUTION_NAME_IDS:
        value = name_table.getDebugName(name_id)
        if value and "Microsoft" in value:
            return True
    return False


def _iter_faces(fonts_dir):
    """Yield (file_name, face_index, TTFont) for every face of every bundled
    .ttf/.ttc under fonts_dir, expanding .ttc collections face by face."""
    for file_name in sorted(os.listdir(fonts_dir)):
        low = file_name.lower()
        path = os.path.join(fonts_dir, file_name)
        if low.endswith(".ttc"):
            coll = TTCollection(path, lazy=True)
            for index in range(len(coll.fonts)):
                yield file_name, index, TTFont(path, fontNumber=index, lazy=True)
        elif low.endswith(".ttf") or low.endswith(".otf"):
            yield file_name, 0, TTFont(path, lazy=True)


def _face_style(os2, head):
    italic = bool(os2.fsSelection & 0x0001) or bool(head.macStyle & 0x0002)
    return "italic" if italic else "normal"


def _weight_range(tt, os2):
    if "fvar" in tt:
        for axis in tt["fvar"].axes:
            if axis.axisTag == "wght":
                return [int(round(axis.minValue)), int(round(axis.maxValue))]
    w = int(os2.usWeightClass)
    return [w, w]


def _stretch_range(tt, os2):
    if "fvar" in tt:
        for axis in tt["fvar"].axes:
            if axis.axisTag == "wdth":
                return [float(axis.minValue), float(axis.maxValue)]
    pct = WIDTH_CLASS_TO_PERCENT.get(int(os2.usWidthClass), 100.0)
    return [pct, pct]


def build_manifest(fonts_dir: str) -> dict:
    families: dict[str, list[dict]] = {}

    def add_face(name, face):
        families.setdefault(name, []).append(face)

    for file_name, index, tt in _iter_faces(fonts_dir):
        if "name" not in tt or "OS/2" not in tt or "head" not in tt:
            continue

        name_table = tt["name"]
        gdi_name = name_table.getDebugName(1)
        if not gdi_name:
            continue
        if not _is_microsoft_supplied(name_table):
            continue

        # Regional-variant aliases (e.g. "MingLiU_HKSCS-ExtB") are internal
        # CJK supplementary-character-set faces Windows does not expose as
        # their own selectable family; no real Windows family name contains
        # an underscore.
        if "_" in gdi_name:
            continue
        # A "<Family> Variable" file is a Microsoft-internal build source for
        # already-bundled static weight instances of <Family> (e.g. "Segoe UI
        # Variable" backs the separately-bundled Segoe UI/Light/Semilight
        # static faces) - not itself a selectable Windows font family.
        if gdi_name.endswith(" Variable"):
            continue

        typo_name = name_table.getDebugName(16)
        wws_name = name_table.getDebugName(21)
        psname = name_table.getDebugName(6) or ""

        os2 = tt["OS/2"]
        head = tt["head"]
        face = {
            "file": file_name,
            "index": index,
            "weight": _weight_range(tt, os2),
            "stretch": _stretch_range(tt, os2),
            "style": _face_style(os2, head),
            "psname": psname,
        }

        family = gdi_name
        if wws_name and wws_name != gdi_name:
            family = wws_name
        elif typo_name and typo_name != gdi_name and gdi_name not in KEEP_GDI_NAME:
            family = typo_name

        add_face(family, face)

        # WWS-base derivation: a compound name with no typographic-family
        # record of its own (Franklin Gothic Medium has neither nameID 16 nor
        # 21) also gets exposed under its weight-word-stripped base family, so
        # both "Franklin Gothic" and "Franklin Gothic Medium" appear, matching
        # the real Windows font list.
        if family == gdi_name and not typo_name and not wws_name:
            words = gdi_name.split(" ")
            if (
                len(words) > 1
                and words[-1] in WEIGHT_WORD_TO_CLASS
                and gdi_name not in KEEP_GDI_NAME
            ):
                base = " ".join(words[:-1])
                if base:
                    add_face(base, dict(face))

    result_families = []
    for name in sorted(families):
        faces = sorted(families[name], key=lambda f: (f["file"].lower(), f["index"]))
        result_families.append({"name": name, "faces": faces})

    return {"families": result_families}


def emit_manifest(manifest: dict) -> str:
    """Serialize the manifest dict to the pipe-delimited line format the C++
    reader consumes. See the module docstring for the grammar."""
    lines = [
        "# bundle-fonts.list v1 - generated by scripts/gen_bundle_font_manifest.py; do not edit by hand"
    ]
    for fam in manifest["families"]:
        lines.append("F|" + fam["name"])
        for fc in fam["faces"]:
            w = fc["weight"]
            s = fc["stretch"]
            lines.append(
                "f|%s|%d|%d|%d|%g|%g|%s|%s"
                % (
                    fc["file"],
                    fc["index"],
                    w[0],
                    w[1],
                    s[0],
                    s[1],
                    fc["style"],
                    fc["psname"],
                )
            )
    return "\n".join(lines) + "\n"


def main():
    scripts_dir = os.path.dirname(os.path.abspath(__file__))
    fonts_dir = os.path.normpath(os.path.join(scripts_dir, "..", "browser", "fonts"))
    manifest = build_manifest(fonts_dir)
    out_path = os.path.join(fonts_dir, "bundle-fonts.list")
    with open(out_path, "w", encoding="ascii", newline="\n") as f:
        f.write(emit_manifest(manifest))
    print(f"wrote {out_path} ({len(manifest['families'])} families)")


if __name__ == "__main__":
    main()
