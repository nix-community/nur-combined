#!/usr/bin/env python3
"""Rewrite fetchDependencies' update_repo() to copy Nix-fetched sources.

MoltenVK's fetchDependencies clones each external project at a pinned revision.
The Nix build prefetches those same revisions; this keeps the script's build
steps but replaces the git clones with local copies.
"""
import os
import re
import sys

path = sys.argv[1]

repos = {
    "cereal": "CEREAL_SRC",
    "SPIRV-Cross": "SPIRV_CROSS_SRC",
    "SPIRV-Tools": "SPIRV_TOOLS_SRC",
    "SPIRV-Tools/external/spirv-headers": "SPIRV_HEADERS_SRC",
    "Volk": "VOLK_SRC",
    "Vulkan-Headers": "VULKAN_HEADERS_SRC",
    "Vulkan-Tools": "VULKAN_TOOLS_SRC",
}

cases = []
for name, env in repos.items():
    src = os.environ[env]
    cases.append(
        f'    "{name}") rm -rf "$1"; mkdir -p "$(dirname "$1")"; cp -R "{src}" "$1"; chmod -R u+w "$1" ;;'
    )

replacement = (
    "function update_repo() {\n"
    '    echo "$1 repo: local Nix source"\n'
    '    case "$1" in\n' + "\n".join(cases) + "\n"
    "        *) echo \"unknown fetchDependencies repo: $1\" >&2; exit 1 ;;\n"
    "    esac\n"
    "}\n"
)

text = open(path).read()
text, count = re.subn(r"function update_repo\(\) \{.*?\n\}\n", replacement, text, flags=re.S)
if count != 1:
    sys.exit(f"{path}: expected one update_repo(), found {count}")
open(path, "w").write(text)
