#!/usr/bin/env xonsh

import requests
from string import Template
import json
import sys
import os


import re

def replace_links(text):
    pattern = r'<a href="([^"]+)">([^<]+)</a>'
    replacement = r'[\2](\1)'
    return re.sub(pattern, replacement, text)



def get_pypi_info(package_name):
    url = f"https://pypi.org/pypi/{package_name}/json"
    headers = {'Accept': 'application/vnd.pypi.simple.v1+json'}
    response = requests.get(url, headers=headers)
    response.raise_for_status()
    js = response.json()
    info = js["info"]
    json.dump(info, open("/tmp/info.json", "w"))
    lines = [x for x in info["description"].split("\n") if not x.strip().startswith("<")]
    try:
        return replace_links(lines[0])
    except KeyError as e:
        print(e)
        print(json.dumps(info, indent=4))
        sys.exit(1)


if len(sys.argv) != 2:
    print(f"usage: {sys.argv[0]} xontrib-package-name")
    sys.exit(1)

xontrib = sys.argv[1]
output_path = os.path.join("pkgs", xontrib)
if not os.path.exists(output_path):
    os.makedirs(output_path)
output = os.path.join(output_path, "default.nix")
desc = get_pypi_info(xontrib)
lines = open(output, "r").read().split("\n")

for i, line in enumerate(lines):
    if line.find("description") > -1:
        lines[i] = f"""description = "[how-to use in nix](https://github.com/drmikecrowe/nur-packages) {desc}";"""
        break
lines = lines[:i+1] + ["  };", "}"]
open(output, "w").write("\n".join(lines))