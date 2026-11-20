#!/usr/bin/env python3
"""Update kytyps5 to the newest upstream `KytyPS5-<date>-<sha>` tag.

The package inlines every 3rdparty submodule gitlink plus the FFmpeg prebuilt
release that matches `ext-ffmpeg-core`, so a version bump alone is never enough:
all of those pins are re-read from the tag's tree here.

The release archives are ordinary tarballs, so their hashes come from
`nix-prefetch-url`; nothing needs a build to be re-pinned (the emulator build is
far too large to run from an update script).
"""

import json
import re
import subprocess
import tempfile
import urllib.request
from pathlib import Path

UPSTREAM = "https://github.com/KytyPS5/KytyPS5.git"
TAG_RE = re.compile(r"^KytyPS5-(\d{4}-\d{2}-\d{2})-([0-9a-f]{7})$")
PKG_REL = Path("by-name/ky/kytyps5/package.nix")

# 3rdparty submodule path -> the GitHub repository the package fetches.
SUBMODULES = {
    "3rdparty/LibAtrac9": ("shadps4-emu", "ext-LibAtrac9"),
    "3rdparty/SDL3": ("libsdl-org", "SDL"),
    "3rdparty/SPIRV-Headers": ("KhronosGroup", "SPIRV-Headers"),
    "3rdparty/SPIRV-Tools": ("KhronosGroup", "SPIRV-Tools"),
    "3rdparty/Vulkan-Headers": ("KhronosGroup", "Vulkan-Headers"),
    "3rdparty/VulkanMemoryAllocator": ("GPUOpen-LibrariesAndSDKs", "VulkanMemoryAllocator"),
    "3rdparty/ffmpeg-core": ("KytyPS5", "ext-ffmpeg-core"),
    "3rdparty/fmt": ("fmtlib", "fmt"),
    "3rdparty/imgui": ("ocornut", "imgui"),
    "3rdparty/magic_enum": ("Neargye", "magic_enum"),
    "3rdparty/nlohmann_json": ("nlohmann", "json"),
    "3rdparty/spdlog": ("gabime", "spdlog"),
    "3rdparty/tracy": ("wolfpld", "tracy"),
    "3rdparty/xxHash": ("Cyan4973", "xxHash"),
    "3rdparty/opus": ("xiph", "opus"),
    "3rdparty/openxr": ("KhronosGroup", "OpenXR-SDK"),
    "3rdparty/xbyak": ("herumi", "xbyak"),
    "3rdparty/zydis": ("zyantific", "zydis"),
    "3rdparty/zycore": ("zyantific", "zycore-c"),
    "3rdparty/zstd": ("facebook", "zstd"),
    "3rdparty/ZArchive": ("Exzap", "ZArchive"),
}


def run(cmd, check=True):
    return subprocess.run(cmd, check=check, text=True, capture_output=True)


def git(*args):
    return run(["git", *args]).stdout.strip()


def latest_tag():
    out = git("ls-remote", "--tags", UPSTREAM, "KytyPS5-*")
    tags = [TAG_RE.match(line.split("refs/tags/")[1]) for line in out.splitlines()]
    tags = [t for t in tags if t]
    if not tags:
        raise SystemExit("error: no dated KytyPS5 tags found upstream")
    match = max(tags, key=lambda t: (t.group(1), t.group(2)))
    date, sha = match.group(1), match.group(2)
    return f"KytyPS5-{date}-{sha}", date


def submodule_revs(tag):
    with tempfile.TemporaryDirectory() as tmp:
        run(["git", "clone", "-q", "--depth=1", "--filter=blob:none",
             "--no-checkout", "--branch", tag, UPSTREAM, tmp])
        tree = git("-C", tmp, "ls-tree", "-r", "HEAD")
    revs = {}
    for line in tree.splitlines():
        meta, path = line.split("\t", 1)
        if meta.startswith("160000 commit "):
            revs[path] = meta.split()[2]
    return revs


def fetch_text(url):
    with urllib.request.urlopen(url) as res:
        return res.read().decode()


def github_slug(url):
    m = re.search(r"github\.com[/:]([^/]+)/([^/]+?)(?:\.git)?$", url.strip())
    if m is None:
        raise SystemExit(f"error: not a GitHub repository: {url}")
    return m.group(1), m.group(2)


def fetchcontent_pins(tag):
    """name -> (owner, repo, rev) from 3rdparty/CMakeLists.txt at `tag`."""
    url = f"https://raw.githubusercontent.com/KytyPS5/KytyPS5/{tag}/3rdparty/CMakeLists.txt"
    lines = fetch_text(url).splitlines()
    pins = {}
    name, body = None, []
    for line in lines:
        stripped = line.strip()
        if name is None and stripped.startswith("FetchContent_Declare"):
            name, body = stripped[len("FetchContent_Declare"):].strip(" (\t"), []
        elif name is not None:
            if stripped.startswith(")"):
                repo = re.search(r"GIT_REPOSITORY\s+(\S+)", "\n".join(body))
                rev = re.search(r"GIT_TAG\s+([0-9a-f]{7,40})", "\n".join(body))
                if repo and rev:
                    owner, repo_name = github_slug(repo.group(1))
                    pins[name] = (owner, repo_name, rev.group(1))
                name = None
            else:
                body.append(line)
    return pins


def submodule_sha(owner, repo, rev, path):
    """Commit a repository's own gitlink points at, via the GitHub API."""
    data = json.loads(
        fetch_text(f"https://api.github.com/repos/{owner}/{repo}/git/trees/{rev}")
    )
    for entry in data.get("tree", []):
        if entry["path"] == path and entry["type"] == "commit":
            return entry["sha"]
    raise SystemExit(f"error: {owner}/{repo}@{rev} has no {path} submodule")


def sri_hash(url):
    raw = run(["nix-prefetch-url", "--unpack", url]).stdout.strip().splitlines()[-1]
    return run(
        ["nix", "hash", "convert", "--hash-algo", "sha256", "--to", "sri", raw]
    ).stdout.strip()


def bump_pin(text, owner, repo, rev, hash_):
    """Rewrite the rev/hash of the single fetchFromGitHub block for owner/repo."""
    pattern = re.compile(
        r'(owner = "' + re.escape(owner) + r'";\s*\n\s*repo = "' + re.escape(repo)
        + r'";\s*\n\s*rev = ")[0-9a-f]+(";\s*\n\s*hash = ")[^"]+(";)'
    )
    match = pattern.search(text)
    if match is None:
        raise SystemExit(f"error: no fetchFromGitHub pin for {owner}/{repo}")
    return pattern.sub(rf"\g<1>{rev}\g<2>{hash_}\g<3>", text, count=1)


def bump_ffmpeg_prebuilt(text, ext_ffmpeg_rev):
    tag = ext_ffmpeg_rev[:12]
    text = re.sub(r"releases/download/[0-9a-f]+/", f"releases/download/{tag}/", text)
    # The archives are keyed by ext-ffmpeg-core's commit, and the hashes are
    # written in darwin-then-linux order inside one `fetchzip` block.
    platforms = ("macos-x64", "linux-x64")
    new_hashes = [
        sri_hash(
            f"https://github.com/KytyPS5/ext-ffmpeg-core/releases/download/{tag}/ffmpeg-{platform}.zip"
        )
        for platform in platforms
    ]
    block = re.search(r"ffmpegPrebuilt = fetchzip \{.*?\n[ \t]*\};", text, re.S)
    if block is None:
        raise SystemExit("error: could not find the ffmpegPrebuilt block")

    pending = iter(new_hashes)
    block_text = re.sub(
        r'"sha256-[^"]+"', lambda _: f'"{next(pending)}"', block.group(0), count=2
    )
    for platform, new_hash in zip(platforms, new_hashes):
        print(f"ffmpeg {platform}: {new_hash}")
    return text.replace(block.group(0), block_text, 1)


def main():
    pkg_nix = Path(git("rev-parse", "--show-toplevel")) / PKG_REL
    text = pkg_nix.read_text()

    tag, date = latest_tag()
    version = f"0-unstable-{date}"
    old_tag = re.search(r'tag = "(KytyPS5-[^"]+)";', text).group(1)
    old_version = re.search(r'(?m)^\s*version = "([^"]+)";', text).group(1)
    print(f"Version: {old_version} -> {version}")
    print(f"Tag:     {old_tag} -> {tag}")
    # Pins are always re-read: a tag can stay put in a stale checkout while the
    # upstream FetchContent revisions move.

    revs = submodule_revs(tag)
    src_hash = sri_hash(f"https://github.com/KytyPS5/KytyPS5/archive/{tag}.tar.gz")
    text = re.sub(r'(?m)^(\s*version = )"[^"]+"', rf'\g<1>"{version}"', text, count=1)
    text = re.sub(r'(?m)^(\s*tag = )"KytyPS5-[^"]+"', rf'\g<1>"{tag}"', text, count=1)
    # Anchor on the tag: the file holds other hashes (the nixpkgs-darwin pin),
    # so the first `hash =` in it is not necessarily the source's.  That pin is
    # bumped by hand, not by this script.
    text = re.sub(
        r'(tag = "KytyPS5-[^"]+";\s*\n\s*hash = ")[^"]+(")',
        rf"\g<1>{src_hash}\g<2>",
        text,
        count=1,
    )

    pins = []
    for path, repo in SUBMODULES.items():
        if path in revs:
            pins.append((*repo, revs[path]))
        else:
            print(f"warning: {path} is no longer a submodule upstream")

    for name, (owner, repo, rev) in fetchcontent_pins(tag).items():
        pins.append((owner, repo, rev))

    # zycore is zydis' own submodule, not a FetchContent entry here.
    zydis = next((p for p in pins if p[1] == "zydis"), None)
    if zydis:
        pins.append(
            ("zyantific", "zycore-c", submodule_sha("zyantific", "zydis", zydis[2], "zycore"))
        )

    for owner, name, rev in pins:
        old = re.search(
            r'repo = "' + re.escape(name) + r'";\s*\n\s*rev = "([0-9a-f]+)"', text
        )
        if old is None:
            raise SystemExit(f"error: no pin for {owner}/{name}")
        if old.group(1) == rev:
            continue
        print(f"{owner}/{name}: {old.group(1)} -> {rev}")
        text = bump_pin(text, owner, name, rev,
                        sri_hash(f"https://github.com/{owner}/{name}/archive/{rev}.tar.gz"))

    text = bump_ffmpeg_prebuilt(text, revs["3rdparty/ffmpeg-core"])
    pkg_nix.write_text(text)
    print(f"kytyps5 {version} pins updated.")


if __name__ == "__main__":
    main()
