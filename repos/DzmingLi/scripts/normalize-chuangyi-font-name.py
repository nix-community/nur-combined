"""Repair CTXingKaiSJ's legacy family names without changing glyphs or metrics.

Usage: python normalize-chuangyi-font-name.py INPUT.ttf OUTPUT.ttf
Requires fonttools. The input font is left untouched.
"""

import argparse
from pathlib import Path

from fontTools.ttLib import TTFont

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("source", type=Path)
parser.add_argument("output", type=Path)
args = parser.parse_args()
if args.source.resolve() == args.output.resolve():
    parser.error("source and output must be different files")

font = TTFont(args.source, recalcTimestamp=False)
names = font["name"]
family = names.getName(1, 3, 1, 0x0409)
if family is None or family.toUnicode() != "创艺简行楷":
    parser.error("expected the CTXingKaiSJ font with Windows family 创艺简行楷")

# Typst can prefer the corrupted Mac family names over the valid Windows names.
# Preserve copyright and all unrelated metadata.
names.names = [
    entry
    for entry in names.names
    if not (entry.platformID == 1 and entry.nameID in (1, 4, 16, 17))
]
for language in (0x0409, 0x0804):
    for name_id, value in (
        (1, "创艺简行楷"),
        (4, "创艺简行楷"),
        (16, "创艺简行楷"),
        (17, "Regular"),
    ):
        names.setName(value, name_id, 3, 1, language)
font.save(args.output)
