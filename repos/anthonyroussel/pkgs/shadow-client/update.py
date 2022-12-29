#! /usr/bin/env nix-shell
#! nix-shell -i python -p python3 -p python3Packages.pyyaml -p python3Packages.packaging nix nix-prefetch-git

import argparse
import json
import subprocess
import sys
import yaml

from packaging.version import Version, parse
from os.path import abspath, dirname
from urllib.request import urlopen

BASE_URL = 'https://storage.googleapis.com/shadow-update/launcher'

FILE = dirname(abspath(__file__)) + '/upstream-info.json'
CHANNELS = ['testing', 'preprod', 'prod']


def fetch_upstream_versions():
    """Loads the given JSON file."""
    result = {}

    for channel in CHANNELS:
        url = f'{BASE_URL}/{channel}/linux/ubuntu_18.04/latest-linux.yml'
        with urlopen(url) as response:
            body = response.read()
            result[channel] = yaml.safe_load(body)

    return result


def load_json(path):
    """Loads the given JSON file."""
    with open(path, 'r') as f:
        return json.load(f)


def commit_upstream_infos(content, commit_message):
    with open(FILE, 'w') as f:
        f.write(json.dumps(content, indent=2))
        f.write('\n')

    subprocess.run(['git', 'add', FILE], check=True)
    subprocess.run(['git', 'commit', '--file=-'], input=commit_message.encode(), check=True)


def parse_args():
    """Parse command line arguments."""
    parser = argparse.ArgumentParser()
    parser.add_argument('--commit', action='store_true')
    parser.add_argument('--channels', nargs='+', default=CHANNELS, choices=CHANNELS)
    return parser.parse_args()


def main() -> int:
    args = parse_args()

    upstream_channels = fetch_upstream_versions()
    current_channels = load_json(FILE)

    for channel in CHANNELS:
        version_old = current_channels[channel]["version"]
        version_new = upstream_channels[channel]["version"]

        # Skip channel if the version did not change
        if parse(version_old) >= parse(version_new):
            continue

        commit_message = 'shadow-{}: {} -> {}'.format(
            channel,
            version_old,
            version_new
        )

        new_content = current_channels
        new_content[channel] = upstream_channels[channel]

        # Commit the upstream-info.json file if needed
        if args.commit:
            commit_upstream_infos(new_content, commit_message)

        print(commit_message)


if __name__ == '__main__':
    sys.exit(main())
