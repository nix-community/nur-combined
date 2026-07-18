#!/usr/bin/env python3
import json
import os
import re
import subprocess
import sys
import tempfile
import urllib.request

PACKAGES = {
    "binance": {
        "type": "custom_deb",
        "url": "https://download.binance.com/electron-desktop/linux/production/binance-amd64-linux.deb",
        "file": "pkgs/binance/default.nix",
    },
    "disbox": {
        "type": "github_release",
        "repo": "naufal-backup/disbox",
        "url_template": "https://github.com/naufal-backup/disbox/releases/download/v{version}/Disbox-Linux-x64.AppImage",
        "file": "pkgs/disbox/default.nix",
    },
    "ghost-downloader-3": {
        "type": "github_release",
        "repo": "XiaoYouChR/Ghost-Downloader-3",
        "url_template": "https://github.com/XiaoYouChR/Ghost-Downloader-3/archive/v{version}.tar.gz",
        "unpack": True,
        "file": "pkgs/ghost-downloader-3/default.nix",
    },
    "streambert": {
        "type": "github_release",
        "repo": "truelockmc/streambert",
        "url_template": "https://github.com/truelockmc/streambert/releases/download/{version}/streambert_{version}_amd64.deb",
        "file": "pkgs/streambert/default.nix",
    },
    "teldrive": {
        "type": "github_release",
        "repo": "tgdrive/teldrive",
        "url_template": "https://github.com/tgdrive/teldrive/releases/download/{version}/teldrive-{version}-linux-amd64.tar.gz",
        "file": "pkgs/teldrive/default.nix",
    },
    "uabea": {
        "type": "github_release",
        "repo": "nesrak1/UABEA",
        "url_template": "https://github.com/nesrak1/UABEA/releases/download/v{version}/uabea-ubuntu.zip",
        "file": "pkgs/uabea/default.nix",
    },
    "vimmdl": {
        "type": "github_commit",
        "repo": "devvratmiglani/Vimmdl",
        "branch": "main",
        "file": "pkgs/vimmdl/default.nix",
    },
}


def fetch_json(url):
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
    with urllib.request.urlopen(req) as response:
        return json.loads(response.read().decode("utf-8"))


def get_latest_github_release(repo):
    data = fetch_json(f"https://api.github.com/repos/{repo}/releases")
    for release in data:
        tag = release["tag_name"]
        if tag == "latest":
            continue
        if tag.startswith("v"):
            tag = tag[1:]
        return tag
    raise Exception(f"No valid version tag found for {repo}")


def get_latest_github_commit(repo, branch):
    data = fetch_json(f"https://api.github.com/repos/{repo}/commits/{branch}")
    sha = data["sha"]
    date = data["commit"]["committer"]["date"][:10]  # YYYY-MM-DD
    return sha, date


def get_nix_hash(url, unpack=False):
    cmd = ["nix-prefetch-url"]
    if unpack:
        cmd.append("--unpack")
    cmd.append(url)
    p = subprocess.run(cmd, capture_output=True, text=True)
    if p.returncode != 0:
        print(f"Error prefetching URL: {url}\n{p.stderr}")
        return None
    base32 = p.stdout.strip()

    s = subprocess.run(
        ["nix", "hash", "to-sri", "--type", "sha256", base32],
        capture_output=True,
        text=True,
    )
    if s.returncode == 0:
        return s.stdout.strip()
    return base32


def update_file(filepath, new_version, new_hash, new_rev=None):
    with open(filepath, "r") as f:
        content = f.read()

    # Handle files with local packages defined before the main package
    split_str = "python3.pkgs.buildPythonApplication rec {"
    if split_str in content:
        parts = content.split(split_str, 1)
        header = parts[0] + split_str
        target = parts[1]
    else:
        header = ""
        target = content

    # Update version
    target = re.sub(
        r'version = "[^"]+";', f'version = "{new_version}";', target, count=1
    )

    # Update hash/sha256
    target = re.sub(r'sha256 = "[^"]+";', f'sha256 = "{new_hash}";', target, count=1)
    target = re.sub(r'hash = "[^"]+";', f'hash = "{new_hash}";', target, count=1)

    # Update rev if present
    if new_rev:
        target = re.sub(r'rev = "[^"]+";', f'rev = "{new_rev}";', target, count=1)

    with open(filepath, "w") as f:
        f.write(header + target)


def update_binance(pkg_name, cfg):
    print(f"Updating {pkg_name}...")
    temp_dir = tempfile.gettempdir()
    deb_path = os.path.join(temp_dir, "binance.deb")

    print(f"Downloading {cfg['url']} to {deb_path}...")
    urllib.request.urlretrieve(cfg["url"], deb_path)

    new_hash = get_nix_hash(cfg["url"])
    if not new_hash:
        return

    print("Extracting version from deb...")
    cmd = [
        "nix",
        "shell",
        "nixpkgs#dpkg",
        "-c",
        "dpkg-deb",
        "-I",
        deb_path,
    ]
    p = subprocess.run(cmd, capture_output=True, text=True)
    if p.returncode != 0:
        print(f"Failed to run dpkg-deb: {p.stderr}")
        return

    version_match = re.search(r"Version:\s*(\S+)", p.stdout)
    if not version_match:
        print("Failed to find Version in deb control info")
        return

    new_version = version_match.group(1)

    with open(cfg["file"], "r") as f:
        current_content = f.read()
    curr_ver_match = re.search(r'version = "([^"]+)";', current_content)
    curr_ver = curr_ver_match.group(1) if curr_ver_match else "unknown"

    if new_version == curr_ver:
        print(f"{pkg_name} is already up to date ({new_version}).")
    else:
        print(f"Updating {pkg_name} from {curr_ver} to {new_version}...")
        update_file(cfg["file"], new_version, new_hash)
        print(f"Successfully updated {pkg_name} to {new_version}!")


def update_github_release(pkg_name, cfg):
    print(f"Updating {pkg_name}...")
    try:
        new_version = get_latest_github_release(cfg["repo"])
    except Exception as e:
        print(f"Failed to fetch release for {pkg_name}: {e}")
        return

    with open(cfg["file"], "r") as f:
        current_content = f.read()
    curr_ver_match = re.search(r'version = "([^"]+)";', current_content)
    curr_ver = curr_ver_match.group(1) if curr_ver_match else "unknown"

    if new_version == curr_ver:
        print(f"{pkg_name} is already up to date ({new_version}).")
        return

    print(
        f"New version found for {pkg_name}: {new_version} (current: {curr_ver})"
    )
    download_url = cfg["url_template"].format(version=new_version)
    print(f"Prefetching {download_url}...")
    new_hash = get_nix_hash(download_url, unpack=cfg.get("unpack", False))
    if not new_hash:
        return

    update_file(cfg["file"], new_version, new_hash)
    print(f"Successfully updated {pkg_name} to {new_version}!")


def update_github_commit(pkg_name, cfg):
    print(f"Updating {pkg_name}...")
    try:
        sha, commit_date = get_latest_github_commit(
            cfg["repo"], cfg["branch"]
        )
    except Exception as e:
        print(f"Failed to fetch commit for {pkg_name}: {e}")
        return

    with open(cfg["file"], "r") as f:
        current_content = f.read()
    curr_rev_match = re.search(r'rev = "([^"]+)";', current_content)
    curr_rev = curr_rev_match.group(1) if curr_rev_match else "unknown"

    if sha == curr_rev:
        print(f"{pkg_name} is already up to date ({sha[:7]}).")
        return

    print(f"New commit found for {pkg_name}: {sha[:7]} ({commit_date})")

    tarball_url = f"https://github.com/{cfg['repo']}/archive/{sha}.tar.gz"
    print(f"Prefetching {tarball_url}...")
    new_hash = get_nix_hash(tarball_url, unpack=True)
    if not new_hash:
        return

    new_version = f"0-unstable-{commit_date}"
    update_file(cfg["file"], new_version, new_hash, new_rev=sha)
    print(f"Successfully updated {pkg_name} to {new_version}!")


def main():
    # Make sure we're in the repository root directory
    script_dir = os.path.dirname(os.path.abspath(__file__))
    repo_root = os.path.dirname(script_dir)
    os.chdir(repo_root)

    if len(sys.argv) > 1:
        pkgs_to_update = sys.argv[1:]
    else:
        pkgs_to_update = list(PACKAGES.keys())

    for pkg in pkgs_to_update:
        if pkg not in PACKAGES:
            print(f"Unknown package: {pkg}")
            continue

        cfg = PACKAGES[pkg]
        if cfg["type"] == "custom_deb":
            update_binance(pkg, cfg)
        elif cfg["type"] == "github_release":
            update_github_release(pkg, cfg)
        elif cfg["type"] == "github_commit":
            update_github_commit(pkg, cfg)

    print("Running nix fmt...")
    subprocess.run(["nix", "fmt"])


if __name__ == "__main__":
    main()
