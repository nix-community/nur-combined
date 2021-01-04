#!/usr/bin/env python3

import urllib.request, urllib.error, json, types
from typing import List, Set, Dict, Optional

# We don't want all those deprecated legacy extensions
# Group extensions by Gnome version for compatibility reasons
supported_versions = {
    "36": {
        "3.36",
        "3.36.0",
        "3.36.1",
        "3.36.2",
        "3.36.3",
        "3.36.4",
        "3.36.5",
        "3.36.6",
    },
    "38": {"3.38", "3.38.0", "3.38.1"},
}


def generate_extension_versions(
    extension_version_map: Dict[str, str], uuid: str
) -> Dict[str, Dict[str, str]]:
    extension_versions: Dict[str, Dict[str, str]] = {}
    for shell_version, sub_versions in supported_versions.items():
        # Newest compatible extension version
        extension_version: Optional[int] = max(
            (
                int(ext_ver)
                for shell_ver, ext_ver in extension_version_map.items()
                if (shell_ver in sub_versions)
            ),
            default=None,
        )
        # Extension is not compatible with this Gnome version
        if not extension_version:
            continue
        print(f"[{shell_version}] Downloading {uuid}, {str(extension_version)}")
        sha256 = fetch_sha256sum(uuid, str(extension_version))
        extension_versions[shell_version] = {
            "version": str(extension_version),
            "sha256": sha256,
        }
    return extension_versions


# Download the extension and hash it
def fetch_sha256sum(uuid: str, version: str) -> str:
    import hashlib, base64

    uuid = uuid.replace("@", "")
    url: str = f"https://extensions.gnome.org/extension-data/{uuid}.v{version}.shell-extension.zip"
    remote = urllib.request.urlopen(url)
    hasher = hashlib.sha256()

    while True:
        data = remote.read(4096)
        if not data:
            break
        hasher.update(data)
    return hasher.hexdigest()


# Fetching extensions
page = 0
extensions = []
while True:
    page += 1
    print("Scraping page " + str(page))
    try:
        with urllib.request.urlopen(
            f"https://extensions.gnome.org/extension-query/?n_per_page=25&page={page}"
        ) as url:
            data = json.loads(url.read().decode())["extensions"]
            responseLength = len(data)
            print(f"Found {responseLength} extensions")

            for extension in data:
                # Yeah, there are some extensions without any releases
                if not extension["shell_version_map"]:
                    continue

                print("Processing " + extension["uuid"])

                # Throw away that 'pk' key. What is it for?
                extension["shell_version_map"] = {
                    k: v["version"] for k, v in extension["shell_version_map"].items()
                }
                # Transform shell_version_map to be more useful for us. Also throw away unwanted versions
                extension["shell_version_map"] = generate_extension_versions(
                    extension["shell_version_map"], extension["uuid"]
                )
                if not extension["shell_version_map"]:
                    # No compatible versions found
                    continue

                # Parse something like "/extension/1475/battery-time/" and output "battery-time-1475"
                def pname_from_url(url: str) -> str:
                    url = url.split("/")  # type: ignore
                    return url[3] + "-" + url[2]

                extension["pname"] = pname_from_url(extension["link"])
                extension["link"] = "https://extensions.gnome.org" + extension["link"]

                # Replace \u0123 in strings. This is required for nix < 2.3.10
                # extension["name"] = extension["name"].encode('unicode-escape').decode()
                # extension["description"] = extension["description"].encode('unicode-escape').decode()

                # Remove unused keys
                del extension["screenshot"]
                del extension["icon"]
                del extension["creator"]
                del extension["creator_url"]
                del extension["pk"]

                extensions += [extension]

            if responseLength < 25:
                break
    except urllib.error.HTTPError as e:
        print("Got error. We're done. (This should be a 404)\n" + str(e))
        break

print(f"Writing results ({len(extensions)} extensions in total)")
with open("extensions.json", "w") as out:
    # Manually pretty-print the outer level, but then do one compact line per extension
    for index, extension in enumerate(extensions):
        if index == 0:
            out.write("[   ")
        else:
            out.write(",   ")
        json.dump(extension, out)
        out.write("\n")
    out.write("]\n")
