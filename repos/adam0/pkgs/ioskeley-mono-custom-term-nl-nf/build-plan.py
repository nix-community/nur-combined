import json
import sys
import tomllib
from pathlib import Path

plans = tomllib.loads(Path(sys.argv[1]).read_text())["buildPlans"]
plan = plans["IoskeleyMono"]
term = plans["IoskeleyMonoTerm"]
for key in ("spacing", "serifs", "noCvSs", "exportGlyphNames", "metricOverride"):
    plan[key] = term[key]
plan["family"] = "Ioskeley Mono Custom Term"
plan["widths"] = {"Normal": plan["widths"]["Normal"]}

# ---------------------------------------------------------------------------
# Reference-font tuning.
#
# Reference metrics, measured from the font and its datasheet, in units
# (upm 1000): advance 600, x-height 518, cap 680, b/d/h/k/l 728,
# typo line 1201, brackets and parens 882 tall, hyphen/equal/plus centre 307.
#
# Every value below was chosen by compiling the candidate, rasterising it at
# the same em size on the same baseline as the reference and scoring pixel IoU
# against it, then confirming by eye. Mean distance over printable ASCII:
# 0.329 -> 0.296 against v2.000, 0.323 -> 0.291 against v2.004.
#
# Provenance: the reference outlines come from a privately licensed copy used
# for measurement only. Nothing is copied from it - no outlines, metrics or
# font data - and no reserved name is used. Every value below selects an
# existing Iosvka variant or metric.
# ---------------------------------------------------------------------------

plan["variants"]["design"].update(
    {
        # Measured better and confirmed by eye:
        #   paren normal       ( ) 0.90 -> 0.56   round contour, not flat-arc
        #   brace straight     { } 0.64 -> 0.43
        #   caret low          ^   0.87 -> 0.44   position only, see the size note
        #   capital-d more-rounded-serifless  D 0.21 -> 0.15
        # Kept from this package's own choices; upstream Ioskeley Mono has no
        # crossbar on 7 and a fourfold @:
        #   seven straight-serifless-crossbar  (v2.000 has the strikethrough, only
        #                                      v2.004 dropped it)
        #   at threefold
        "paren": "normal",
        "brace": "straight",
        "caret": "low",
        "capital-d": "more-rounded-serifless",
        "seven": "straight-serifless-crossbar",
        "at": "threefold",
    }
)

plan["metricOverride"].update(
    {
        # Measured better and confirmed by eye.
        "cap": 680,  # was 690; reference cap height is 680
        "leading": 1200,  # was 1250; reference typo line is 1201
        "symbolMid": 307,  # was Iosvka's 340; reference puts - = + at 307
        "parenSize": 850,  # was 860; puts parens at the reference 882-unit height
        # Caret, grave and tilde are all too large (486x375, 277x358, 506x322
        # against the reference's 359x257, 185x142, 441x187). accentWidth is the
        # only lever that shrinks them: 280 takes the caret to 269 tall and the
        # grave to 257, the best combined score of 182 / 280 / 320 / 400. It also
        # widens diacritics on accented letters; that cost was reviewed and
        # accepted.
        "accentWidth": 280,  # was 182
    }
)

# ---------------------------------------------------------------------------
# Sizes that cannot be tuned. Tested and reverted:
#
# * Bracket, paren and brace width is baked into the glyphs: the reference
#   paren is 258 units wide, Iosvka's narrowest is 317. parenSize moves height
#   only, and lowering it wrecks the brackets and slashes (parenSize 600 takes
#   [ ] to 0.93 and / to 0.64, mean 0.296 -> 0.326). The reference also pulls
#   ( 45 units right and ) 45 units left; no key translates a glyph sideways.
# * The caret and grave arms are the sidebearing span, so the only way to
#   shorten them is sb, which shrinks every letter with them: at sb 110 the
#   caret arms go 478 -> 428 but H goes 430 -> 380 against the reference's 444
#   and the mean over ASCII 0.296 -> 0.381. Rejected; sb stays at 85 and the
#   arms stay wider than the reference's.
# * The asterisk is 484x458 against the reference's 425x404; only its position
#   is a knob, not its size.
# ---------------------------------------------------------------------------

json.dump({"buildPlans": {"IosevkaIoskeleyMonoCustomTerm": plan}}, sys.stdout)
