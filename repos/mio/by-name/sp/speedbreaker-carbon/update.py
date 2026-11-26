#!/usr/bin/env python3
"""Update SpeedBreaker: Carbon and the recompiler pin from its setup script."""

import json
import re
import subprocess
import urllib.request
from pathlib import Path

REPO = "SpeedBreakerProject/speedbreaker-carbon"
PKG_REL = Path("by-name/sp/speedbreaker-carbon/package.nix")
FAKE_HASH = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="


def run(cmd, check=True):
    return subprocess.run(cmd, check=check, text=True, capture_output=True)


def get_text(url):
    req = urllib.request.Request(
        url,
        headers={
            "Accept": "application/vnd.github+json",
            "User-Agent": "nurpkgs3-update-script",
        },
    )
    with urllib.request.urlopen(req) as response:
        return response.read().decode()


def get_json(url):
    return json.loads(get_text(url))


def sri_hash(url, unpack=False):
    command = ["nix", "store", "prefetch-file", "--json"]
    if unpack:
        command.insert(3, "--unpack")
    command.append(url)
    result = run(command)
    return json.loads(result.stdout)["hash"]


def current_system():
    return run(
        ["nix", "eval", "--raw", "--impure", "--expr", "builtins.currentSystem"]
    ).stdout.strip()


def replace_once(text, pattern, replacement, label):
    text, count = re.subn(pattern, replacement, text, count=1, flags=re.S | re.M)
    if count != 1:
        raise SystemExit(f"error: expected one {label} match in package.nix")
    return text


def xenon_hash(attr_path):
    result = run(
        ["nix", "build", attr_path, "--no-link"],
        check=False,
    )
    match = re.search(r"got:\s+(sha256-[A-Za-z0-9+/=]+)", result.stderr)
    if match is None:
        raise SystemExit(
            "error: could not determine XenonRecomp hash\n" + result.stderr[-2000:]
        )
    return match.group(1)


def main():
    root = Path(run(["git", "rev-parse", "--show-toplevel"]).stdout.strip())
    pkg_nix = root / PKG_REL
    original = pkg_nix.read_text()
    text = original

    release = get_json(f"https://api.github.com/repos/{REPO}/releases/latest")
    tag = release["tag_name"]
    version = tag.removeprefix("v")
    source_url = f"https://github.com/{REPO}/archive/refs/tags/{tag}.tar.gz"
    source_hash = sri_hash(source_url, unpack=True)

    setup_url = f"https://raw.githubusercontent.com/{REPO}/{tag}/scripts/setup_tools.sh"
    setup_script = get_text(setup_url)
    xenon_match = re.search(
        r"^\s*XENONRECOMP_BASE=([0-9a-f]{40})\b", setup_script, re.M
    )
    if xenon_match is None:
        raise SystemExit("error: upstream setup_tools.sh has no XENONRECOMP_BASE pin")
    xenon_rev = xenon_match.group(1)
    xenon_commit = get_json(
        f"https://api.github.com/repos/hedge-dev/XenonRecomp/commits/{xenon_rev}"
    )
    xenon_version = f"0-unstable-{xenon_commit['commit']['committer']['date'][:10]}"
    ffmpeg_match = re.search(
        r"^\s*FFMPEG_VERSION=([0-9.]+)\b", setup_script, re.M
    )
    if ffmpeg_match is None:
        raise SystemExit("error: upstream setup_tools.sh has no FFMPEG_VERSION pin")
    ffmpeg_version = ffmpeg_match.group(1)
    ffmpeg_url = f"https://ffmpeg.org/releases/ffmpeg-{ffmpeg_version}.tar.xz"
    ffmpeg_hash = sri_hash(ffmpeg_url)

    old_version = re.search(r'(?m)^\s*version = "([^"]+)";', text).group(1)
    old_xenon_rev = re.search(
        r'(?ms)^  xenonrecompSrc = fetchFromGitHub \{\n.*?^\s*rev = "([^"]+)";',
        text,
    ).group(1)

    print(f"Version: {old_version} -> {version}")
    print(f"XenonRecomp: {old_xenon_rev} -> {xenon_rev} ({xenon_version})")
    print(f"FFmpeg: -> {ffmpeg_version}")

    text = replace_once(
        text,
        r'(?ms)^  src = fetchFromGitHub \{\n.*?owner = "SpeedBreakerProject";.*?^\s*\};',
        f'''  src = fetchFromGitHub {{
    owner = "SpeedBreakerProject";
    repo = "speedbreaker-carbon";
    tag = "v${{version}}";
    hash = "{source_hash}";
  }};''',
        "SpeedBreaker source block",
    )
    text = replace_once(
        text,
        r'(?m)^\s*version = "[^"]+";',
        f'  version = "{version}";',
        "version",
    )
    text = replace_once(
        text,
        r'(?ms)^  xenonrecompSrc = fetchFromGitHub \{\n.*?owner = "hedge-dev";.*?^\s*\};',
        f'''  xenonrecompSrc = fetchFromGitHub {{
    owner = "hedge-dev";
    repo = "XenonRecomp";
    rev = "{xenon_rev}";
    fetchSubmodules = true;
    hash = "{FAKE_HASH}";
  }};''',
        "XenonRecomp source block",
    )
    text = replace_once(
        text,
        r'(?ms)(^  xenonrecomp = clangStdenv.mkDerivation \{\n.*?^\s*version = )"[^"]+"',
        rf'\g<1>"{xenon_version}"',
        "XenonRecomp package version",
    )
    text = replace_once(
        text,
        r'(?ms)(^  ffmpegXma = stdenv.mkDerivation \{\n.*?^\s*version = )"[^"]+"',
        rf'\g<1>"{ffmpeg_version}"',
        "FFmpeg version",
    )
    text = replace_once(
        text,
        r'(?ms)^    src = fetchurl \{\n.*?^\s*\};',
        f'''    src = fetchurl {{
      url = "{ffmpeg_url}";
      hash = "{ffmpeg_hash}";
    }};''',
        "FFmpeg source block",
    )
    pkg_nix.write_text(text)

    attr = f".#legacyPackages.{current_system()}.speedbreaker-carbon.xenonrecompSrc"
    try:
        new_xenon_hash = xenon_hash(attr)
    except BaseException:
        pkg_nix.write_text(original)
        raise
    text = pkg_nix.read_text().replace(FAKE_HASH, new_xenon_hash, 1)
    pkg_nix.write_text(text)
    print(f"XenonRecomp hash: {new_xenon_hash}")

    build = run(
        [
            "nix",
            "build",
            f".#legacyPackages.{current_system()}.speedbreaker-carbon",
            "--no-link",
        ],
        check=False,
    )
    if build.returncode != 0:
        pkg_nix.write_text(original)
        raise SystemExit(
            f"error: {version} does not build, keeping the previous pin\n"
            + build.stderr[-2000:]
        )

    print(f"SpeedBreaker: Carbon {version} builds; package.nix updated.")


if __name__ == "__main__":
    main()
