#!/usr/bin/env python3

import json
from subprocess import run, PIPE
from urllib.request import urlopen

url = "https://gerrit.wikimedia.org/r/plugins/gitiles/mediawiki/core/+refs/tags?format=JSON"

# i should make this do the string replacement, then call nix-update, but i'm lazy
#with open('default.nix', 'r', encoding='utf-8') as f:
#    default_nix = f.read()

attr_names_cmd = ['nix-instantiate', '--eval', '--json', '--expr', 'builtins.attrNames (import ./default.nix {})']

attr_names_output = run(attr_names_cmd, encoding='utf-8', stdout=PIPE, stderr=PIPE)

attr_names: list[str] = json.loads(attr_names_output.stdout)

latest_versions: dict[str, list[str]] = {}

with urlopen(url) as response:
    response.readline() # skip intentional garbage line
    mediawiki_tags_raw = json.load(response)

# TODO: actually handle beta releases maybe
for release in mediawiki_tags_raw.keys():
    values: tuple[int, int, int]
    try:
        values = tuple(int(x) for x in release.split('.'))
    except ValueError:
        continue

    major_ver = 'mediawiki_{}_{}'.format(*values)
    if major_ver in latest_versions:
        if latest_versions[major_ver] < values:
            latest_versions[major_ver] = values
    else:
        latest_versions[major_ver] = values

for nix_attr, version_tuple in latest_versions.items():
    if nix_attr in attr_names:
        version_str = '{}.{}.{}'.format(*version_tuple)
        print('Updating', nix_attr, '->', version_str)
        run(["nix-update", "--override-filename=default.nix", "--version=" + version_str, nix_attr])
        run(["nix-update", "--override-filename=default.nix", "--version=skip", nix_attr + "_core"])
