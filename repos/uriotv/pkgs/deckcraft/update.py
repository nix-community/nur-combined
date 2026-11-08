#!/usr/bin/env python3
"""Update the official deckcraft binary release."""
import runpy
import sys
from pathlib import Path
sys.argv.insert(1, "deckcraft")
runpy.run_path(str(Path(__file__).resolve().parents[2] / "scripts/update-artcraft.py"), run_name="__main__")
