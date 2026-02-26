#!/usr/bin/env nix-shell
#! nix-shell -i python -p "python3.withPackages (ps: with ps; [ps.requests ])"

import os
import hashlib
import base64
import json
import time

import requests


class Version:
    def __init__(self, name: str):
        self.name: str = name
        self.hash: str | None = None
        self.url: str | None = None


class VersionManager:
    def __init__(self, base_url: str = "https://api.vintagestory.at"):
        self.versions: list[Version] = []
        self.base_url: str = base_url


    def fetch_versions(self):
        """
        Fetch all versions
        """
        response = requests.get(f'{self.base_url}/stable.json')

        try:
            response.raise_for_status()

        except requests.exceptions.HTTPError as e:
            print(e)
            return

        versions = response.json()
        for version_name in versions:
            print(f"Fetching version {version_name}")

            version = Version(version_name)

            if 'linuxserver' in versions[version_name]:
                version.url = versions[version_name]["linuxserver"]["urls"]["cdn"]
            elif 'server' in versions[version_name]:
                version.url = versions[version_name]["server"]["urls"]["cdn"]

            # the api provides md5 hashes but sha256 is prefered for nix
            version.hash = self.download_and_generate_sha256_hash(version.url)

            self.versions.append(version)

            print(f"Version {version.name} fetched")


    def versions_to_json(self):
        return json.dumps(
            {version.name: {'hash': version.hash, 'url': version.url}
                for version in self.versions},
            indent=4
        )


    def find_version_json() -> str:
        """
        Find the versions.json file in the same directory as this script
        """
        return os.path.join(os.path.dirname(os.path.realpath(__file__)), "versions.json")


    def write_versions(self, file_name: str = find_version_json()):
        """ write all processed versions to json """
        # save json to versions.json
        with open(file_name, 'w') as f:
            f.write(self.versions_to_json() + "\n")


    @staticmethod
    def download_and_generate_sha256_hash(url: str) -> str | None:
        """
        Fetch the tarball from the given URL.
        Then generate a sha256 hash of the tarball.
        """

        success = False
        while success is False:
            try:
                # Download the file from the URL
                response = requests.get(url, timeout=20)
                response.raise_for_status()
                success = True

            except Exception as e:
                print(f"Error: {e}")
                time.sleep(10)


        # Create a new SHA-256 hash object
        sha256_hash = hashlib.sha256()

        # Update the hash object with chunks of the downloaded content
        for byte_block in response.iter_content(4096):
            sha256_hash.update(byte_block)

        # Get the hexadecimal representation of the hash
        hash_value = sha256_hash.digest()

        # Encode the hash value in base64
        base64_hash = base64.b64encode(hash_value).decode('utf-8')

        # Format it as "sha256-{base64_hash}"
        sri_representation = f"sha256-{base64_hash}"

        return sri_representation


if __name__ == '__main__':
    version_manager = VersionManager()

    version_manager.fetch_versions()
    version_manager.write_versions()
