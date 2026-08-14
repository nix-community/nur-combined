#!/usr/bin/env python3
"""Export cabi_realloc wrapping TinyGo's realloc (4-arg component ABI)."""

import re
import sys
from pathlib import Path


def main() -> None:
    src = Path(sys.argv[1])
    dst = Path(sys.argv[2])
    text = src.read_text()
    match = re.search(r'\(export "realloc" \(func ([^)]+)\)\)', text)
    if not match:
        raise SystemExit("no realloc export in " + str(src))
    target = match.group(1).strip()
    wrapper = f"""
  (func $cabi_realloc (param i32 i32 i32 i32) (result i32)
    local.get 0
    local.get 3
    call {target})
  (export "cabi_realloc" (func $cabi_realloc))
"""
    idx = text.rfind(")")
    dst.write_text(text[:idx] + wrapper + "\n" + text[idx:])


if __name__ == "__main__":
    main()
