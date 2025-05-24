import argparse
import base64
import hashlib
import itertools
import json
import sys

import requests


def clac_hash(url):
    try:
        response = requests.get(url)
        response.raise_for_status()

        sha256 = hashlib.sha256(response.content).hexdigest()
        base64_hash = base64.b64encode(bytes.fromhex(sha256)).decode("utf-8")
        return base64_hash
    except requests.RequestException as e:
        print(f"Error fetching URL {url}: {e}")
        return ""


def generate_hashes(version):
    fontSize = ["16px", "12px", "10px"]
    fontStyle = ["proportional", "monospaced"]
    fontType = ["ttf", "ttc", "otc", "otf", "woff2", "bdf", "pcf"]

    targets = itertools.product(fontSize, fontStyle, fontType)
    result = {}

    for target in targets:
        fontSize, fontStyle, fontType = target
        flattened_target = f"ark-pixel-font-{fontSize}-{fontStyle}-{fontType}"
        url = f"https://github.com/TakWolf/ark-pixel-font/releases/download/{version}/{flattened_target}-v{version}.zip"
        print(f"Generating hash for {flattened_target}")
        hash = clac_hash(url)
        result[flattened_target] = f"sha256-{hash}"
    return result


if __name__ == "__main__":
    parser = argparse.ArgumentParser("Generate hashes for ark-pixel-font")
    parser.add_argument(
        "-v", "--version", type=str, required=True, help="The version of the font to generate hashes for"
    )
    args = parser.parse_args()

    try:
        version = args.version
        hashes = generate_hashes(version)
        with open("hashes.json", "w") as f:
            json.dump(hashes, f, indent=2)
        print(f"Hashes for version {version} generated successfully.")
    except Exception as e:
        print(f"Error: {str(e)}")
        sys.exit(1)
