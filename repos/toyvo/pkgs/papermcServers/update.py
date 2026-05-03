#!/usr/bin/env nix-shell
#! nix-shell -i python -p "python3.withPackages (ps: with ps; [ps.requests ])"

import os
import hashlib
import base64
import json

import requests


GRAPHQL_URL = "https://fill.papermc.io/graphql"


class Version:
    def __init__(self, name: str):
        self.name: str = name
        self.hash: str | None = None
        self.build_number: int | None = None

    @property
    def full_name(self):
        v_name = f"{self.name}-{self.build_number}"

        if not self.name or not self.build_number:
            print(f"Warning: version '{v_name}' contains NoneType!")

        return v_name


class VersionManager:
    def __init__(self):
        self.versions: list[Version] = []
        self.existing_versions: dict = {}
        versions_json_path = self.find_version_json()
        if os.path.exists(versions_json_path):
            with open(versions_json_path, 'r') as f:
                self.existing_versions = json.load(f)

    def graphql_query(self, query: str, variables: dict | None = None) -> dict:
        """Execute a GraphQL query and return the data."""
        payload = {"query": query}
        if variables:
            payload["variables"] = variables
        response = requests.post(GRAPHQL_URL, json=payload, headers={"content-type": "application/json"})
        response.raise_for_status()
        result = response.json()
        if "errors" in result:
            raise RuntimeError(f"GraphQL errors: {result['errors']}")
        return result["data"]

    def fetch_versions(self, not_before_minor_version: int = 14):
        """Fetch all stable Paper versions from the GraphQL API."""
        query = """
        query {
          project(key: "paper") {
            versions(first: 100) {
              nodes {
                key
                family {
                  key
                }
              }
            }
          }
        }
        """
        data = self.graphql_query(query)
        version_nodes = data["project"]["versions"]["nodes"]

        for node in version_nodes:
            version_name = node["key"]
            family = node["family"]["key"]

            # Skip pre-releases and release candidates
            if 'pre' in version_name or 'rc' in version_name:
                continue

            # Filter by version number
            # Support both 1.X.Y and 26.X formats
            try:
                parts = version_name.split(".")
                if len(parts) >= 2:
                    major = int(parts[0])
                    minor = int(parts[1])
                    if major > 1 or (major == 1 and minor >= not_before_minor_version):
                        self.versions.append(Version(version_name))
            except ValueError:
                continue

    def fetch_latest_builds(self):
        """Fetch the latest build number and hash for each version."""
        for version in self.versions:
            query = """
            query($version: String!) {
              project(key: "paper") {
                version(key: $version) {
                  builds(last: 1) {
                    nodes {
                      number
                      downloads {
                        name
                        url
                        checksums {
                          sha256
                        }
                      }
                    }
                  }
                }
              }
            }
            """
            data = self.graphql_query(query, {"version": version.name})
            build_nodes = data["project"]["version"]["builds"]["nodes"]

            if not build_nodes:
                print(f"No builds found for version {version.name}")
                continue

            build = build_nodes[0]
            version.build_number = build["number"]

            # Find the application download (the main jar)
            downloads = build.get("downloads", [])
            download = None
            for d in downloads:
                if d["name"].endswith(".jar"):
                    download = d
                    break

            if not download:
                print(f"No jar download found for version {version.full_name}")
                continue

            # Check cache
            existing = self.existing_versions.get(version.name)
            if existing and existing.get('version') == version.full_name:
                version.hash = existing['hash']
                print(f"Version {version.full_name} already cached")
                continue

            # Convert hex sha256 to SRI format (base64)
            hex_hash = download["checksums"]["sha256"]
            hash_bytes = bytes.fromhex(hex_hash)
            b64_hash = base64.b64encode(hash_bytes).decode('utf-8')
            version.hash = f"sha256-{b64_hash}"
            print(f"Version {version.full_name} fetched")

    def versions_to_json(self):
        return json.dumps(
            {version.name: {'hash': version.hash, 'version': version.full_name}
                for version in self.versions},
            indent=4
        )

    @staticmethod
    def find_version_json() -> str:
        """Find the versions.json file in the same directory as this script."""
        return os.path.join(os.path.dirname(os.path.realpath(__file__)), "versions.json")

    def write_versions(self, file_name: str = find_version_json()):
        """Write all processed versions to json."""
        with open(file_name, 'w') as f:
            f.write(self.versions_to_json() + "\n")


if __name__ == '__main__':
    version_manager = VersionManager()

    version_manager.fetch_versions()
    version_manager.fetch_latest_builds()
    version_manager.write_versions()
