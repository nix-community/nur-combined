from pathlib import Path
from scriptipy import *
import json

data = json.loads(Path("gradle.lock").read_bytes())
flat = [
    (k, k2, v2)
    for (k, v) in data.items()
    for (k2, v2) in v.items()
    if v2["url"].startswith("https://maven.pkg.github.com/")
]
filenames = set(filename for (_, filename, _) in flat)
cache_paths = [
    p for p in Path("~/.gradle/caches").expanduser().glob("**") if p.name in filenames
]
for p in cache_paths:
    run("nix", "store", "add", "--mode", "flat", p).must_succeed()
