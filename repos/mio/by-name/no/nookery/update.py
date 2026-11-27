#!/usr/bin/env nix-shell
#! nix-shell -i python3 -p python3 nix nix-update git gnutar

import re
import subprocess
import tarfile
import tempfile
import urllib.request
from pathlib import Path


PKG_REL = Path("by-name/no/nookery/package.nix")


def run(args, check=True):
    return subprocess.run(
        args,
        check=check,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )


def sri_unpack_hash(url):
    base32 = run(["nix-prefetch-url", "--unpack", url]).stdout.strip().splitlines()[-1]
    return run(
        ["nix", "hash", "convert", "--hash-algo", "sha256", "--to", "sri", base32]
    ).stdout.strip()


def download(url, target):
    request = urllib.request.Request(url, headers={"User-Agent": "nurpkgs-update"})
    with urllib.request.urlopen(request) as response, target.open("wb") as out:
        out.write(response.read())


def sri_flat_archive_hash(url):
    with tempfile.TemporaryDirectory() as tmp:
        tmp_path = Path(tmp)
        archive = tmp_path / "archive.tar.gz"
        root = tmp_path / "root"
        root.mkdir()
        download(url, archive)
        with tarfile.open(archive) as tar:
            extra = {"filter": "data"} if hasattr(tarfile, "data_filter") else {}
            tar.extractall(root, **extra)
        return run(["nix", "hash", "path", str(root)]).stdout.strip()


def replace_block(text, name, block, kind):
    pattern = rf"(?ms)^  {name} = {kind} \{{\n.*?^  \}};"
    text, count = re.subn(pattern, block, text, count=1)
    if count != 1:
        raise SystemExit(f"error: expected one {name} block in {PKG_REL}")
    return text


def replace_once(text, pattern, replacement, label):
    text, count = re.subn(pattern, replacement, text, count=1, flags=re.M)
    if count != 1:
        raise SystemExit(f"error: expected one {label} in {PKG_REL}")
    return text


def main():
    root = Path(run(["git", "rev-parse", "--show-toplevel"]).stdout.strip())
    package = root / PKG_REL
    original = package.read_text()

    run(["nix-update", "nookery"])

    system = run(
        ["nix", "eval", "--raw", "--impure", "--expr", "builtins.currentSystem"]
    ).stdout.strip()
    source = Path(
        run(
            [
                "nix",
                "build",
                f".#legacyPackages.{system}.nookery.src",
                "--no-link",
                "--print-out-paths",
            ]
        )
        .stdout.strip()
        .splitlines()[-1]
    )

    aurora_versions = (source / "extern/aurora/cmake/AuroraDependencyVersions.cmake").read_text()
    dawn_version = re.search(
        r'^_aurora_dependency_version\(AURORA_DAWN_VERSION "([^"]+)"', aurora_versions, re.M
    ).group(1)
    nod_version = re.search(
        r'^_aurora_dependency_version\(AURORA_NOD_VERSION "([^"]+)"', aurora_versions, re.M
    ).group(1)

    dawn_url = (
        "https://github.com/encounter/dawn/releases/download/"
        f"{dawn_version}/dawn-linux-x86_64.tar.gz"
    )
    nod_url = (
        "https://github.com/encounter/nod/releases/download/"
        f"{nod_version}/libnod-linux-x86_64.tar.gz"
    )

    aurora_imgui = (source / "extern/aurora/cmake/AuroraDearImguiProvider.cmake").read_text()
    imgui_url = re.search(
        r"URL (https://github\.com/ocornut/imgui/archive/[^\n]+\.tar\.gz)", aurora_imgui
    ).group(1)
    aurora_extern = (source / "extern/aurora/extern/CMakeLists.txt").read_text()
    rmlui_rev = re.search(
        r"URL https://github\.com/encounter/RmlUi/archive/([0-9a-f]{40})\.tar\.gz",
        aurora_extern,
    ).group(1)
    tracy_url = re.search(
        r"URL (https://github\.com/wolfpld/tracy/archive/[^\n]+)", aurora_extern
    ).group(1)

    borealis_curl = (source / "extern/borealis/cmake/BorealisCurl.cmake").read_text()
    curl_url = re.search(
        r"URL (https://github\.com/curl/curl/releases/download/[^\n]+)", borealis_curl
    ).group(1)

    dawn_hash = sri_flat_archive_hash(dawn_url)
    nod_hash = sri_flat_archive_hash(nod_url)
    imgui_hash = sri_unpack_hash(imgui_url)
    rmlui_hash = sri_unpack_hash(
        f"https://github.com/encounter/RmlUi/archive/{rmlui_rev}.tar.gz"
    )
    tracy_hash = sri_unpack_hash(tracy_url)
    curl_hash = sri_unpack_hash(curl_url)

    text = package.read_text()
    text = replace_once(
        text,
        r'^  dawnVersion = "([^"]+)";',
        f'  dawnVersion = "{dawn_version}";',
        "dawnVersion",
    )
    text = replace_once(
        text,
        r'^  nodVersion = "([^"]+)";',
        f'  nodVersion = "{nod_version}";',
        "nodVersion",
    )
    text = replace_block(
        text,
        "dawnPrebuilt",
        f'''  dawnPrebuilt = fetchzip {{
    url = "https://github.com/encounter/dawn/releases/download/${{dawnVersion}}/dawn-linux-x86_64.tar.gz";
    hash = "{dawn_hash}";
    stripRoot = false;
  }};''',
        "fetchzip",
    )
    text = replace_block(
        text,
        "nodPrebuilt",
        f'''  nodPrebuilt = fetchzip {{
    url = "https://github.com/encounter/nod/releases/download/${{nodVersion}}/libnod-linux-x86_64.tar.gz";
    hash = "{nod_hash}";
    stripRoot = false;
  }};''',
        "fetchzip",
    )
    text = replace_block(
        text,
        "imgui",
        f'''  imgui = fetchzip {{
    url = "{imgui_url}";
    hash = "{imgui_hash}";
  }};''',
        "fetchzip",
    )
    text = replace_block(
        text,
        "rmlui",
        f'''  rmlui = fetchFromGitHub {{
    owner = "encounter";
    repo = "RmlUi";
    rev = "{rmlui_rev}";
    hash = "{rmlui_hash}";
  }};''',
        "fetchFromGitHub",
    )
    text = replace_block(
        text,
        "tracy",
        f'''  tracy = fetchzip {{
    url = "{tracy_url}";
    hash = "{tracy_hash}";
  }};''',
        "fetchzip",
    )
    text = replace_block(
        text,
        "curlSrc",
        f'''  curlSrc = fetchzip {{
    url = "{curl_url}";
    hash = "{curl_hash}";
  }};''',
        "fetchzip",
    )

    package.write_text(text)
    run(["nix", "fmt", str(PKG_REL)])

    build = run(["nix", "build", f".#legacyPackages.{system}.nookery", "--no-link"], check=False)
    if build.returncode != 0:
        package.write_text(original)
        raise SystemExit(
            "error: updated Nookery does not build; restored the previous pins\n"
            + build.stderr[-3000:]
        )

    print(
        f"Nookery pins updated: dawn {dawn_version}, nod {nod_version}, "
        f"RmlUi {rmlui_rev}, curl {curl_url}"
    )


if __name__ == "__main__":
    main()
