#!/usr/bin/env nix-shell
#! nix-shell -i python -p "python3.withPackages (ps: with ps; [ps.requests ])"

import os
import hashlib
import base64
import json

import requests


class Version:
    def __init__(self, name: str):
        self.name: str = name
        self.hash: str | None = None
        self.loader_version: int | None = None
        self.installer_version: int | None = None

    @property
    def full_name(self):
        v_name = f"{self.name}-{self.loader_version}-{self.installer_version}"

        # this will probably never happen because the download of a build with NoneType in URL would fail
        if not self.name or not self.loader_version or not self.installer_version:
            print(f"Warning: version '{v_name}' contains NoneType!")

        return v_name


class VersionManager:
    def __init__(self, base_url: str = "https://meta.fabricmc.net/v2/versions"):
        self.versions: list[Version] = []
        self.base_url: str = base_url

    def fetch_versions(self, not_before_minor_version: int = 14):
        """
        Fetch all versions after given minor release
        """

        response = requests.get(f"{self.base_url}/game")

        try:
            response.raise_for_status()

        except requests.exceptions.HTTPError as e:
            print(e)
            return

        # we only want versions that are no pre-releases
        release_versions = filter(
            lambda v: v['stable'], response.json())

        for v in release_versions:

            # split version string, convert to list ot int
            version_split = v['version'].split(".")
            version_split = list(map(int, version_split))

            # check if version is higher than 1.<not_before_sub_version>
            if (version_split[0] > 1) or (version_split[0] == 1 and version_split[1] >= not_before_minor_version):
                self.versions.append(Version(v['version']))

    def fetch_latest_loader_version(self):
        """
        Set latest build number to each version
        """

        for version in self.versions:
            url = f"{self.base_url}/loader"
            response = requests.get(url)

            # check that we've got a good response
            try:
                response.raise_for_status()

            except requests.exceptions.HTTPError as e:
                print(e)
                return

            stable_loaders = list(filter(lambda v: v['stable'], response.json()))
            latest_loader = stable_loaders[0]
            for loader in stable_loaders:
                major, minor, patch = map(int, loader['version'].split('.'))
                lmajor, lminor, lpatch = map(int, latest_loader['version'].split('.'))
                if major > lmajor or (major == lmajor and minor > lminor) or (major == lmajor and minor == lminor and patch > lpatch):
                    latest_loader = loader
            version.loader_version = latest_loader['version']

    def fetch_latest_installer_version(self):
        """
        Set latest installer version to each version
        """

        for version in self.versions:
            url = f"{self.base_url}/installer"
            response = requests.get(url)

            # check that we've got a good response
            try:
                response.raise_for_status()

            except requests.exceptions.HTTPError as e:
                print(e)
                return

            stable_installers = list(filter(lambda v: v['stable'], response.json()))
            latest_installer = stable_installers[0]
            for installer in stable_installers:
                major, minor, patch = map(int, installer['version'].split('.'))
                lmajor, lminor, lpatch = map(int, latest_installer['version'].split('.'))
                if major > lmajor or (major == lmajor and minor > lminor) or (major == lmajor and minor == lminor and patch > lpatch):
                    latest_installer = installer
            version.installer_version = latest_installer['version']

    def generate_version_hashes(self):
        """
        Generate and set the hashes for all registered versions (versions will are downloaded to memory)
        """

        for version in self.versions:
            url = f"{self.base_url}/loader/{version.name}/{version.loader_version}/{version.installer_version}/server/jar"
            version.hash = self.download_and_generate_sha256_hash(url)

    def versions_to_json(self):
        return json.dumps(
            {version.name: {'hash': version.hash, 'version': version.full_name}
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

        try:
            # Download the file from the URL
            response = requests.get(url)
            response.raise_for_status()

        except requests.exceptions.RequestException as e:
            print(f"Error: {e}")
            return None

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
    version_manager.fetch_latest_loader_version()
    version_manager.fetch_latest_installer_version()
    version_manager.generate_version_hashes()
    version_manager.write_versions()
