import json
import os
import re
import subprocess
import sys
from typing import Dict, List

import requests


def get_script_path() -> str:
    return os.path.dirname(os.path.realpath(sys.argv[0]))


def get_codecs() -> List[str]:
    session = requests.Session()
    session.headers.update(
        {
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.67 Safari/537.36"
        }
    )
    page = session.get("https://downloads.digium.com/pub/telephony/").text
    return re.findall(r'href="codec_([^/]+)/"', page)


def get_versions(name: str) -> Dict[str, Dict[str, str]]:
    session = requests.Session()
    session.headers.update(
        {
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.67 Safari/537.36"
        }
    )
    versions_page = session.get(
        f"https://downloads.digium.com/pub/telephony/codec_{name}/"
    ).text

    versions = re.findall(r'href="asterisk-([0-9\.]+)/"', versions_page)
    bits = ["32", "64"]

    result = {}
    for version in versions:
        for bit in bits:
            try:
                download_url = f"https://downloads.digium.com/pub/telephony/codec_{name}/asterisk-{version}/x86-{bit}/"
                download_page = session.get(download_url).text

                filenames = re.findall(
                    rf'href="(codec_{name}-{version}_([0-9\.]+)[^"]+)"', download_page
                )
                latest_filename = filenames[0]
                for filename in filenames:
                    current_version = filename[1]
                    for a, b in zip(
                        current_version.split("."), latest_filename[1].split(".")
                    ):
                        if int(a) > int(b):
                            latest_filename = filename
                            break

                if version not in result:
                    result[version] = {}
                result[version][bit] = download_url + latest_filename[0]
            except KeyboardInterrupt:
                raise
            except Exception as e:
                print(
                    f"Cannot get download URL for {name}, asterisk {version}, {bit} bit: {e}"
                )
                continue

    return result


def nix_prefetch_url(url: str):
    result = subprocess.run(["nix-prefetch-url", url], stdout=subprocess.PIPE)
    if result.returncode != 0:
        raise RuntimeError(f"nix-prefetch-url exited with error {result.returncode}")
    return result.stdout.decode("utf-8").strip()


def add_versions(name: str, result: dict):
    versions = get_versions(name)

    for asterisk_version, bits in versions.items():
        if asterisk_version.count(".") == 1 and asterisk_version.endswith(".0"):
            major = asterisk_version.split(".")[0]
        else:
            major = asterisk_version

        if major not in result:
            result[major] = {}
        if name not in result[major]:
            result[major][name] = {}

        for bit, url in bits.items():
            if bit not in result[major][name]:
                codec_version = re.search(
                    rf"/codec_{name}-{asterisk_version}_([0-9\.]+)",
                    url,
                )[1]
                result[major][name][bit] = {
                    "url": url,
                    "version": codec_version,
                    "hash": nix_prefetch_url(url),
                }


# Load existing records
try:
    with open(get_script_path() + "/sources.json") as f:
        result = json.load(f)
except Exception:
    result = {}

for library in get_codecs():
    if library == "g729":
        # g729 module is the same as g729a
        continue
    add_versions(library, result)

# Write as json
with open(get_script_path() + "/sources.json", "w") as f:
    f.write(json.dumps(result, indent=4, sort_keys=True))
