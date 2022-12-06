#!/usr/bin/env python3

import json
import pkg_resources
import sys

def check_requirements(manifest_file):
    with open(manifest_file) as f:
        manifest = json.load(f)
    if 'requirements' in manifest:
        requirements = manifest['requirements']
        pkg_resources.require(requirements)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        raise RuntimeError(f"Usage {sys.argv[0]} <manifest>")
    manifest_file = sys.argv[1]
    check_requirements(manifest_file)
