#!/usr/bin/env python3
import requests
from bs4 import BeautifulSoup
import re
import sys


def get_latest_version():
    url = "https://debrepo.freedownloadmanager.org/pool/main/f/freedownloadmanager/"

    try:
        response = requests.get(url)
        response.raise_for_status()

        soup = BeautifulSoup(response.text, "html.parser")

        # Find all .deb files
        deb_files = []
        for link in soup.find_all("a", href=True):
            href = link["href"]
            if href.endswith(".deb") and "amd64" in href:
                deb_files.append(href)

        if not deb_files:
            print("No .deb files found", file=sys.stderr)
            sys.exit(1)

        # Extract version numbers
        versions = []
        version_pattern = r"freedownloadmanager_(\d+\.\d+\.\d+\.\d+)_amd64\.deb"

        for deb_file in deb_files:
            match = re.search(version_pattern, deb_file)
            if match:
                version = match.group(1)
                versions.append(version)

        if not versions:
            print("No valid versions found", file=sys.stderr)
            sys.exit(1)

        # Find the latest version
        latest_version = max(versions, key=lambda v: [int(x) for x in v.split(".")])

        print(latest_version)

    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    get_latest_version()
