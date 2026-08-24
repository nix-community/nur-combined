#!/usr/bin/env python3
"""Behavior tests for Stable/Beta release discovery without network access."""

import json
import pathlib
import subprocess
import textwrap


ROOT = pathlib.Path(__file__).resolve().parents[1]
UPDATER = ROOT / "config/includes.chroot/usr/local/sbin/moonlight-update"
source = UPDATER.read_text(encoding="utf-8")
functions = source.split('\ncase "${1:---menu}" in\n', 1)[0]


def discover(channel, releases=None, expected_code=0):
    payload = json.dumps(releases or [])
    harness = textwrap.dedent(
        f"""
        load_update_channel() {{ UPDATE_CHANNEL={channel}; }}
        curl() {{ printf '%s' '{payload}'; }}
        die() {{ printf 'error=%s\\n' "$1"; exit 23; }}
        discover_release
        printf 'channel=%s\\ntag=%s\\nmanifest=%s\\nsignature=%s\\n' \\
            "$UPDATE_CHANNEL" "$AVAILABLE_TAG" "$MANIFEST_URL" "$SIGNATURE_URL"
        """
    )
    result = subprocess.run(
        ["/bin/sh"], input=functions + "\n" + harness,
        text=True, capture_output=True, check=False,
    )
    assert result.returncode == expected_code, result.stderr + result.stdout
    return result.stdout


stable = discover("stable")
assert "channel=stable" in stable
assert "tag=\n" in stable
assert "/releases/latest/download/moonlight-os-update.txt" in stable

beta = discover("beta", [
    {"tag_name": "v9.0.0", "prerelease": False, "draft": False},
    {"tag_name": "v0.2.8-beta.2", "prerelease": True, "draft": True},
    {"tag_name": "v0.2.8-beta.1", "prerelease": True, "draft": False},
    {"tag_name": "v0.2.7-beta.3", "prerelease": True, "draft": False},
])
assert "channel=beta" in beta
assert "tag=v0.2.8-beta.1" in beta
assert "/releases/download/v0.2.8-beta.1/moonlight-os-update.txt" in beta

bad = discover("beta", [
    {"tag_name": "v0.2.8-beta.1/unsafe", "prerelease": True, "draft": False},
], expected_code=23)
assert "invalid prerelease tag" in bad

missing = discover("beta", [
    {"tag_name": "v0.2.8", "prerelease": False, "draft": False},
], expected_code=23)
assert "no Moonlight OS prerelease" in missing

print("Moonlight OS updater channels: ok")
