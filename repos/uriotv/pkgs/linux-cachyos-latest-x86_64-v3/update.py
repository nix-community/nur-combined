#!/usr/bin/env python3
"""Update this package's CachyOS latest source pin."""
from pathlib import Path
import runpy
import sys

ROOT = Path(__file__).resolve().parents[2]
sys.argv[1:1] = [str(Path(__file__).resolve().parent), "latest"]
runpy.run_path(str(ROOT / "scripts" / "update-cachyos.py"), run_name="__main__")
