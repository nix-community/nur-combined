#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p python3

import json

with open("nix/sources.json", "r") as f:
    sources = json.loads(f.read())

with open("README.md", "w") as f:
    list = "| Name | Description |\n| ---- | ----------- |"
    for plugin, meta in sources.items():
        sanitized_name = plugin.replace(".", "-")
        list += f'\n| [{sanitized_name}](https://github.com/{meta["owner"]}/{meta["repo"]}) | {meta["description"]} |'
    f.write(list)
