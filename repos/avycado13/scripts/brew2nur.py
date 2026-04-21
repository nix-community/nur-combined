#!/usr/bin/env python3
"""
brew2nur - Convert Homebrew formulae and casks into NUR Nix package derivations.

Usage:
    ./brew2nur.py <formula-or-cask-name> [--cask] [--tap TAP] [--output-dir DIR]

Examples:
    ./brew2nur.py ripgrep
    ./brew2nur.py rectangle --cask
    ./brew2nur.py bat --output-dir ../pkgs
    ./brew2nur.py myformula --tap owner/tap-name
"""

import argparse
import json
import os
import ssl
import subprocess
import sys
import textwrap
import urllib.request
from pathlib import Path
from typing import Optional, Tuple, List

HOMEBREW_FORMULA_API = "https://formulae.brew.sh/api/formula/{}.json"
HOMEBREW_CASK_API = "https://formulae.brew.sh/api/cask/{}.json"

# For custom taps, we'll use the GitHub raw API
# Tap format: owner/repo or owner/homebrew-repo
HOMEBREW_TAP_FORMULA_RAW = "https://raw.githubusercontent.com/{tap}/HEAD/Formula/{name}.rb"
HOMEBREW_TAP_CASK_RAW = "https://raw.githubusercontent.com/{tap}/HEAD/Casks/{name}.rb"

LICENSE_MAP = {
    "MIT": "licenses.mit",
    "Apache-2.0": "licenses.asl20",
    "GPL-2.0": "licenses.gpl2Only",
    "GPL-2.0-only": "licenses.gpl2Only",
    "GPL-2.0-or-later": "licenses.gpl2Plus",
    "GPL-3.0": "licenses.gpl3Only",
    "GPL-3.0-only": "licenses.gpl3Only",
    "GPL-3.0-or-later": "licenses.gpl3Plus",
    "LGPL-2.1": "licenses.lgpl21Only",
    "LGPL-3.0": "licenses.lgpl3Only",
    "BSD-2-Clause": "licenses.bsd2",
    "BSD-3-Clause": "licenses.bsd3",
    "ISC": "licenses.isc",
    "MPL-2.0": "licenses.mpl20",
    "Unlicense": "licenses.unlicense",
    "Zlib": "licenses.zlib",
    "WTFPL": "licenses.wtfpl",
    "CC0-1.0": "licenses.cc0",
    "Artistic-2.0": "licenses.artistic2",
    "BSL-1.0": "licenses.boost",
    "AGPL-3.0-only": "licenses.agpl3Only",
    "AGPL-3.0-or-later": "licenses.agpl3Plus",
}


def fetch_json(url: str) -> dict:
    try:
        ctx = ssl.create_default_context()
        with urllib.request.urlopen(url, context=ctx) as resp:
            return json.loads(resp.read().decode())
    except (urllib.error.URLError, ssl.SSLError):
        # Fallback for environments with missing/broken CA certs (e.g. uv-managed Python)
        ctx = ssl._create_unverified_context()
        try:
            with urllib.request.urlopen(url, context=ctx) as resp:
                return json.loads(resp.read().decode())
        except urllib.error.HTTPError as e:
            print(f"Error fetching {url}: {e}", file=sys.stderr)
            sys.exit(1)
    except urllib.error.HTTPError as e:
        print(f"Error fetching {url}: {e}", file=sys.stderr)
        sys.exit(1)


def fetch_from_tap(tap: str, name: str, is_cask: bool = False) -> Optional[dict]:
    """
    Fetch formula/cask from a custom tap using brew command.
    
    Args:
        tap: Tap name (e.g., 'owner/tap-name' or 'owner/homebrew-tap-name')
        name: Package name
        is_cask: Whether this is a cask
    
    Returns:
        Dictionary with package info or None if not found
    """
    try:
        # Use brew --json to get package info from tap
        pkg_ref = f"{tap}/{name}"
        cmd = ["brew", "info", pkg_ref, "--json=v2"]
        
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
        if result.returncode == 0:
            data = json.loads(result.stdout)
            if is_cask:
                casks = data.get("casks", [])
                return casks[0] if casks else None
            else:
                formulae = data.get("formulae", [])
                return formulae[0] if formulae else None
        else:
            print(f"Error: {result.stderr}", file=sys.stderr)
    except (subprocess.TimeoutExpired, json.JSONDecodeError) as e:
        print(f"Error fetching from tap {tap}: {e}", file=sys.stderr)
    except FileNotFoundError:
        print("Error: 'brew' command not found. Install Homebrew first.", file=sys.stderr)
    
    return None


def nix_license(brew_license: Optional[str]) -> str:
    if not brew_license:
        return "licenses.unfree"
    # Homebrew uses SPDX with some extras; handle simple cases and AND/OR
    clean = brew_license.strip().strip('"')
    if clean in LICENSE_MAP:
        return LICENSE_MAP[clean]
    return f'licenses.unfreeRedistributable  # TODO: map "{clean}" to nixpkgs license'


def prefetch_url(url: str) -> str:
    """Use nix-prefetch-url to get the hash for a URL."""
    try:
        result = subprocess.run(
            ["nix-prefetch-url", "--type", "sha256", "--unpack", url],
            capture_output=True,
            text=True,
            check=True,
        )
        nix_hash = result.stdout.strip()
        # Convert to SRI hash
        result2 = subprocess.run(
            ["nix", "hash", "to-sri", "--type", "sha256", nix_hash],
            capture_output=True,
            text=True,
            check=True,
        )
        return result2.stdout.strip()
    except (subprocess.CalledProcessError, FileNotFoundError):
        return "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=  # TODO: run nix-prefetch-url"


def prefetch_github(owner: str, repo: str, rev: str) -> str:
    """Use nix-prefetch-url to get the hash for a GitHub tarball."""
    url = f"https://github.com/{owner}/{repo}/archive/{rev}.tar.gz"
    return prefetch_url(url)


def guess_github_info(urls: List[str]) -> Optional[Tuple[str, str]]:
    """Try to extract owner/repo from homepage or URLs."""
    for url in urls:
        if "github.com" in url:
            parts = url.rstrip("/").split("github.com/")
            if len(parts) == 2:
                segments = parts[1].split("/")
                if len(segments) >= 2:
                    return segments[0], segments[1].removesuffix(".git")
    return None


def generate_formula_nix(data: dict, do_prefetch: bool) -> str:
    name = data["name"]
    version = data["versions"]["stable"]
    desc = data["desc"] or ""
    homepage = data["homepage"] or ""
    license_str = data.get("license") or ""

    urls_to_check = [homepage] + [
        u.get("url", "") for u in data.get("urls", {}).values()
    ]
    # Also check the stable source URL
    stable_url = data.get("urls", {}).get("stable", {}).get("url", "")
    if stable_url:
        urls_to_check.insert(0, stable_url)

    gh = guess_github_info(urls_to_check)

    nix_lic = nix_license(license_str)

    if gh:
        owner, repo = gh
        rev = f"v{version}"

        if do_prefetch:
            src_hash = prefetch_github(owner, repo, rev)
        else:
            src_hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=  # TODO: replace with real hash"

        return textwrap.dedent(f"""\
            {{
              lib,
              stdenv,
              fetchFromGitHub,
            }}:

            stdenv.mkDerivation rec {{
              pname = "{name}";
              version = "{version}";

              src = fetchFromGitHub {{
                owner = "{owner}";
                repo = "{repo}";
                rev = "v${{version}}";
                hash = "{src_hash}";
              }};

              # TODO: add buildInputs / nativeBuildInputs as needed
              # TODO: add buildPhase / installPhase as needed

              installPhase = ''
                runHook preInstall
                mkdir -p $out/bin
                # TODO: install binaries / files
                runHook postInstall
              '';

              meta = with lib; {{
                description = "{desc}";
                homepage = "{homepage}";
                license = {nix_lic};
                maintainers = [ ];
                platforms = platforms.unix;
              }};
            }}
        """)
    else:
        if do_prefetch and stable_url:
            src_hash = prefetch_url(stable_url)
        else:
            src_hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=  # TODO: replace with real hash"

        return textwrap.dedent(f"""\
            {{
              lib,
              stdenv,
              fetchurl,
            }}:

            stdenv.mkDerivation rec {{
              pname = "{name}";
              version = "{version}";

              src = fetchurl {{
                url = "{stable_url}";
                hash = "{src_hash}";
              }};

              # TODO: add buildInputs / nativeBuildInputs as needed
              # TODO: add buildPhase / installPhase as needed

              installPhase = ''
                runHook preInstall
                mkdir -p $out/bin
                # TODO: install binaries / files
                runHook postInstall
              '';

              meta = with lib; {{
                description = "{desc}";
                homepage = "{homepage}";
                license = {nix_lic};
                maintainers = [ ];
                platforms = platforms.unix;
              }};
            }}
        """)


def generate_cask_nix(data: dict, do_prefetch: bool) -> str:
    name = data["token"]
    version = data["version"]
    desc = data.get("desc") or ""
    homepage = data.get("homepage") or ""
    url = data.get("url") or ""

    # Casks can have per-arch URLs via variations or url interpolation
    # We handle the simple case here
    app_name = ""
    artifacts = data.get("artifacts", [])
    for artifact in artifacts:
        if isinstance(artifact, dict) and "app" in artifact:
            apps = artifact["app"]
            if apps:
                app_name = apps[0] if isinstance(apps[0], str) else apps[0]
                break

    if do_prefetch and url:
        download_url = url.replace("#{version}", version)
        try:
            result = subprocess.run(
                ["nix-prefetch-url", "--type", "sha256", download_url],
                capture_output=True,
                text=True,
                check=True,
            )
            nix_hash = result.stdout.strip()
            result2 = subprocess.run(
                ["nix", "hash", "to-sri", "--type", "sha256", nix_hash],
                capture_output=True,
                text=True,
                check=True,
            )
            src_hash = result2.stdout.strip()
        except (subprocess.CalledProcessError, FileNotFoundError):
            src_hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=  # TODO: replace with real hash"
    else:
        src_hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=  # TODO: replace with real hash"

    # Replace #{version} with Nix interpolation
    nix_url = url.replace("#{version}", "${version}")

    if app_name:
        install_phase = textwrap.dedent(f"""\
          installPhase = ''
            runHook preInstall
            mkdir -p $out/Applications
            cp -r "{app_name}" $out/Applications/
            runHook postInstall
          '';""")
    else:
        install_phase = textwrap.dedent("""\
          installPhase = ''
            runHook preInstall
            mkdir -p $out/Applications
            # TODO: copy .app bundle to $out/Applications/
            runHook postInstall
          '';""")

    unpack_tool = (
        "undmg"
        if url.endswith(".dmg")
        else "unzip  # TODO: pick undmg or unzip based on archive type"
    )

    lines = [
        "{",
        "  lib,",
        "  stdenvNoCC,",
        "  fetchurl,",
        "  undmg ? null,",
        "  unzip ? null,",
        "}:",
        "",
        "stdenvNoCC.mkDerivation rec {",
        f'  pname = "{name}";',
        f'  version = "{version}";',
        "",
        "  src = fetchurl {",
        f'    url = "{nix_url}";',
        f'    hash = "{src_hash}";',
        "  };",
        "",
        "  nativeBuildInputs = [",
        f"    {unpack_tool}",
        "  ];",
        "",
        '  sourceRoot = ".";',
        "",
    ]

    # Add install phase
    for line in install_phase.splitlines():
        lines.append(f"  {line}" if line.strip() else "")

    lines += [
        "",
        "  meta = with lib; {",
        f'    description = "{desc}";',
        f'    homepage = "{homepage}";',
        "    license = licenses.unfree;  # Most casks are proprietary",
        "    maintainers = [ ];",
        "    platforms = platforms.darwin;",
        "  };",
        "}",
        "",
    ]

    return "\n".join(lines)


def register_in_default_nix(pkg_name: str, default_nix_path: Path):
    """Add the package to default.nix if not already present."""
    content = default_nix_path.read_text()
    entry = f"  {pkg_name} = pkgs.callPackage ./pkgs/{pkg_name} {{ }};"
    if entry in content:
        print(f"  {pkg_name} already registered in default.nix")
        return
    # Insert before the closing brace
    closing = content.rstrip().rfind("}")
    if closing == -1:
        print("  Warning: could not find closing brace in default.nix", file=sys.stderr)
        return
    new_content = content[:closing] + f"\n{entry}\n" + content[closing:]
    default_nix_path.write_text(new_content)
    print(f"  Added {pkg_name} to default.nix")


def main():
    parser = argparse.ArgumentParser(
        description="Convert Homebrew formulae/casks into NUR Nix packages"
    )
    parser.add_argument("name", help="Homebrew formula or cask name")
    parser.add_argument(
        "--cask", action="store_true", help="Treat as a cask instead of a formula"
    )
    parser.add_argument(
        "--tap",
        default=None,
        help="Custom tap (e.g., 'owner/tap-name'). Omit to search main Homebrew repo",
    )
    parser.add_argument(
        "--output-dir",
        default=None,
        help="Output directory for the package (default: ./pkgs/<name>)",
    )
    parser.add_argument(
        "--no-prefetch",
        action="store_true",
        help="Skip prefetching hashes (leave TODOs instead)",
    )
    parser.add_argument(
        "--register",
        action="store_true",
        help="Add the package to default.nix automatically",
    )
    args = parser.parse_args()

    brew_name = args.name.lower().strip()
    is_cask = args.cask
    do_prefetch = not args.no_prefetch
    tap = args.tap

    pkg_type = 'cask' if is_cask else 'formula'
    tap_str = f" from tap '{tap}'" if tap else " from main Homebrew repo"
    print(f"Fetching {pkg_type} info for '{brew_name}'{tap_str}...")

    if tap:
        # Fetch from custom tap
        data = fetch_from_tap(tap, brew_name, is_cask)
        if not data:
            print(f"Error: {pkg_type} '{brew_name}' not found in tap '{tap}'", file=sys.stderr)
            sys.exit(1)
    else:
        # Fetch from main Homebrew repo
        if is_cask:
            url = HOMEBREW_CASK_API.format(brew_name)
            data = fetch_json(url)
        else:
            url = HOMEBREW_FORMULA_API.format(brew_name)
            data = fetch_json(url)
    
    if is_cask:
        nix_content = generate_cask_nix(data, do_prefetch)
        pkg_name = data["token"]
    else:
        nix_content = generate_formula_nix(data, do_prefetch)
        pkg_name = data["name"]

    # Determine output directory
    script_dir = Path(__file__).resolve().parent
    repo_root = script_dir.parent

    if args.output_dir:
        out_dir = Path(args.output_dir) / pkg_name
    else:
        out_dir = repo_root / "pkgs" / pkg_name

    out_dir.mkdir(parents=True, exist_ok=True)
    out_file = out_dir / "default.nix"

    if out_file.exists():
        print(f"Warning: {out_file} already exists. Overwrite? [y/N] ", end="")
        if input().strip().lower() != "y":
            print("Aborted.")
            sys.exit(0)

    out_file.write_text(nix_content)
    print(f"Generated {out_file}")

    if args.register:
        default_nix = repo_root / "default.nix"
        if default_nix.exists():
            register_in_default_nix(pkg_name, default_nix)

    print()
    print("Next steps:")
    print(f"  1. Review and edit {out_file}")
    print("  2. Fill in any TODOs (build inputs, install phase, hash)")
    print(f"  3. Test with: nix-build -A {pkg_name}")
    if not args.register:
        print(
            f"  4. Add to default.nix:  {pkg_name} = pkgs.callPackage ./pkgs/{pkg_name} {{ }};"
        )
        print(f"     Or re-run with --register to do this automatically.")


if __name__ == "__main__":
    main()
