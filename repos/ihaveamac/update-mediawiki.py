#!/usr/bin/env python3

import json
from subprocess import run, PIPE
from urllib.request import urlopen

url = "https://endoflife.date/api/v1/products/mediawiki/"

# i should make this do the string replacement, then call nix-update, but i'm lazy
#with open('default.nix', 'r', encoding='utf-8') as f:
#    default_nix = f.read()

attr_names_cmd = ['nix-instantiate', '--eval', '--json', '--expr', 'builtins.attrNames (import ./default.nix {})']

attr_names_output = run(attr_names_cmd, encoding='utf-8', stdout=PIPE, stderr=PIPE)

attr_names: list[str] = json.loads(attr_names_output.stdout)

with urlopen(url) as response:
    mediawiki_releases_raw = json.load(response)

mediawiki_releases: dict[str, str] = {}
for release in mediawiki_releases_raw["result"]["releases"]:
    mediawiki_releases[release["name"]] = release["latest"]["name"]

print(mediawiki_releases)

for branch, version in mediawiki_releases.items():
    print(branch, version)
    nix_attr = "mediawiki_{}_{}".format(*branch.split('.'))
    print(nix_attr)
    if nix_attr in attr_names:
        run(["nix-update", "--override-filename=default.nix", "--version=" + version, nix_attr])
        run(["nix-update", "--override-filename=default.nix", "--version=skip", nix_attr + "_core"])
