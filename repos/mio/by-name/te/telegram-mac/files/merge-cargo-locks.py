"""Collect locked external crates for fetchCargoVendor, without resolving them.

This synthetic lockfile is only a download manifest. Each actual Cargo build
continues to use its unmodified upstream lockfile with --locked and offline mode.
"""

import json
import sys
import tomllib
from pathlib import Path

packages = {}
for filename in sys.argv[1:]:
    for package in tomllib.loads(Path(filename).read_text())["package"]:
        if "source" not in package:
            continue
        key = (package["name"], package["version"], package["source"])
        if key in packages:
            assert packages[key].get("checksum") == package.get("checksum"), key
        packages[key] = package

print("version = 4")
for key in sorted(packages):
    print("\n[[package]]")
    for field in ("name", "version", "source", "checksum"):
        if field in packages[key]:
            print(f"{field} = {json.dumps(packages[key][field])}")
