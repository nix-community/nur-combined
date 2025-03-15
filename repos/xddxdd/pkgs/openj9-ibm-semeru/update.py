#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p python3 -p python3Packages.requests
import ast
import json
import os
import re
import sys

import requests

sources = requests.get(
    "https://developer.ibm.com/middleware/v1/contents/static/semeru-runtime-downloads"
).json()
sources = sources["results"][0]["pagepost_custom_js_value"]

# Find body of json value
sources = re.match(r"let sourceDataJson = ([^;]+);", sources).group(1)

# Reformat into python dict format
sources = sources.replace("'", '"')
sources = re.sub(r"^\s+([^\s]+)\s*:", r'"\1":', sources, flags=re.MULTILINE)
sources = sources.replace("true", "True")
sources = sources.replace("false", "False")

# Load dict
sources = ast.literal_eval(sources)
sources = sources["downloads"]

# Reformat source


def get_script_path():
    return os.path.dirname(os.path.realpath(sys.argv[0]))


def version_to_number(v):
    vs = [int(vv) for vv in v.split(".")]
    while len(vs) < 4:
        vs.append(0)
    return vs[0] * 1000000000 + vs[1] * 1000000 + vs[2] * 1000 + vs[3]


def find_tar_gz_link(v):
    for k in v:
        if v[k]["displayName"].endswith("tar.gz"):
            return v[k]
    return None


formatted_source = {}
for source in sources:
    if "arch" not in source:
        continue

    if "os" not in source:
        continue
    if source["os"].lower() != "linux":
        continue

    if source["license"].upper() != "GPL":
        continue

    major_revision = source["version"]
    version = re.search(r"<b>(.*)</b>", source["name"]).group(1)

    arch = source["arch"]
    if arch == "x64":
        arch = "x86_64"

    jre = find_tar_gz_link(source["jre"]) if "jre" in source else None
    if jre is None:
        continue
    jdk = find_tar_gz_link(source["jdk"]) if "jdk" in source else None
    if jdk is None:
        continue

    def add_java_revision(key):
        if ("jdk-bin-" + key) not in formatted_source:
            formatted_source["jdk-bin-" + key] = {}
        if ("jre-bin-" + key) not in formatted_source:
            formatted_source["jre-bin-" + key] = {}

        if arch in formatted_source["jdk-bin-" + key]:
            if version_to_number(
                formatted_source["jdk-bin-" + key][arch]["version"]
            ) > version_to_number(version):
                return

        formatted_source["jre-bin-" + key][arch] = {
            "version": version,
            "type": "jre",
            "url": jre["downloadLink"],
            "sha256": re.sub(r"[^0-9a-fA-F]", "", jre["checksum"]),
        }
        formatted_source["jdk-bin-" + key][arch] = {
            "version": version,
            "type": "jdk",
            "url": jdk["downloadLink"],
            "sha256": re.sub(r"[^0-9a-fA-F]", "", jdk["checksum"]),
        }

    add_java_revision(str(major_revision))
    add_java_revision(version.replace(".", "_"))

# Write as json
with open(get_script_path() + "/sources.json", "w") as f:
    f.write(json.dumps(formatted_source, indent=4))
