#!/usr/bin/env python3
"""Canonicalize CSS for cross-compiler equivalence checks.

Reads CSS on stdin, writes a canonical form on stdout. Beyond whitespace, this
folds away the *serialization* differences between dart-sass 1.x and grass
0.13 that are semantically meaningless:

  - rgb()/rgba() with fractional or integer channels  -> rounded #rrggbb / #rrggbbaa
  - 3-digit hex (#abc)                                 -> 6-digit (#aabbcc)
  - hex is lowercased

It does NOT reorder declarations or rules, so genuine ordering/structure
divergences (e.g. dart-sass hoisting bare declarations after nested rules) are
preserved and will still show up in a diff. Run this on both outputs, then
`diff` the results to see only the non-serialization differences.
"""
import re
import sys


def round_hex(r, g, b, a=None):
    def c(x):
        return max(0, min(255, round(x)))
    s = "#%02x%02x%02x" % (c(r), c(g), c(b))
    if a is not None:
        # alpha 0..1 -> 0..255
        s += "%02x" % c(a * 255)
    return s


def expand_short_hex(m):
    h = m.group(1)
    return "#" + "".join(ch * 2 for ch in h).lower()


def sub_rgb(m):
    parts = [p.strip() for p in m.group(2).split(",")]
    nums = []
    for p in parts:
        try:
            if p.endswith("%"):
                nums.append(float(p[:-1]) * 255.0 / 100.0)
            else:
                nums.append(float(p))
        except ValueError:
            # Non-numeric channel — e.g. rgba(var(--x), .5) or a space-syntax
            # rgb(r g b / a). Not a serialization difference; leave verbatim.
            return m.group(0)
    if len(nums) == 4:
        return round_hex(nums[0], nums[1], nums[2], nums[3])
    return round_hex(nums[0], nums[1], nums[2])


def canon(text):
    # rgb(...) / rgba(...) -> hex
    text = re.sub(r"\b(rgba?)\(([^)]*)\)", sub_rgb, text)
    # [a="b"] -> [a=b] when the value is a valid CSS identifier (dart-sass
    # unquotes these; other compilers keep the author's quotes)
    text = re.sub(
        r"\[([-\w]+)([~^$*|]?=)\"([A-Za-z_-][\w-]*)\"\]", r"[\1\2\3]", text
    )
    # #abc -> #aabbcc ; lowercase 6-digit hex
    text = re.sub(r"#([0-9a-fA-F]{3})\b", expand_short_hex, text)
    text = re.sub(
        r"#([0-9a-fA-F]{6,8})\b", lambda m: "#" + m.group(1).lower(), text
    )
    # whitespace normalization, line-oriented
    text = re.sub(r"[ \t\n]+", " ", text)
    text = re.sub(r"\s*([{};,])\s*", r"\1", text)
    text = text.replace("}", "}\n").replace(";", ";\n").replace("{", "{\n")
    lines = [ln.strip() for ln in text.splitlines() if ln.strip()]
    return "\n".join(lines) + "\n"


if __name__ == "__main__":
    sys.stdout.write(canon(sys.stdin.read()))
