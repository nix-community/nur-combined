#!/usr/bin/env nix-shell
#!nix-shell -i python3 --pure --keep GITHUB_TOKEN -p python3 nix curl cacert
# ruff: noqa: EXE005

import json
import re
import subprocess
import sys
from dataclasses import dataclass
from datetime import datetime, timezone
from functools import total_ordering
from pathlib import Path
from typing import NamedTuple

SCRIPT_DIR = Path(__file__).resolve().parent
SOURCES_NIX = SCRIPT_DIR / "sources.nix"
SRI_SCRIPT = SCRIPT_DIR / "../../.github/script/fetch-sri-hash.sh"

PLATFORM_KEYS = ("aarch64-darwin", "aarch64-linux", "x86_64-linux")


@total_ordering
@dataclass(frozen=True)
class Version:
    semver: tuple[int, ...]
    date_str: str

    @property
    def full(self) -> str:
        semver_str = ".".join(str(x) for x in self.semver)
        return f"{semver_str}-{self.date_str}"

    def __lt__(self, other: "Version") -> bool:
        if self.semver != other.semver:
            return self.semver < other.semver
        return self.date_str < other.date_str

    @classmethod
    def parse_url(cls, url: str, fallback_date: str | None = None) -> "Version":
        filename = url.split("/")[-1]
        semver_match = re.search(
            r"[Qq][Qq](?:[Nn][Tt])?[-._]?([0-9]+(?:\.[0-9]+)+)", filename
        )
        if not semver_match:
            raise ValueError(f"Cannot parse SemVer from: {filename} (URL: {url})")
        semver = tuple(int(x) for x in semver_match.group(1).split("."))

        match_8d = re.search(
            r"_([2][0-9]{3})([0-1][0-9])([0-3][0-9])(?=_|\.|$)", filename
        )
        if match_8d:
            ver_date = f"{match_8d.group(1)}-{match_8d.group(2)}-{match_8d.group(3)}"
        else:
            match_6d = re.search(
                r"_([0-9]{2})([0-1][0-9])([0-3][0-9])(?=_|\.|$)", filename
            )
            if match_6d:
                ver_date = (
                    f"20{match_6d.group(1)}-{match_6d.group(2)}-{match_6d.group(3)}"
                )
            else:
                ver_date = (
                    fallback_date
                    if (
                        fallback_date
                        and re.match(r"^\d{4}-\d{2}-\d{2}$", fallback_date)
                    )
                    else datetime.now(tz=timezone.utc).date().isoformat()
                )

        return cls(semver=semver, date_str=ver_date)

    @classmethod
    def from_exact_str(cls, ver_str: str) -> "Version":
        match = re.match(r"^(\d+(?:\.\d+)+)-(\d{4}-\d{2}-\d{2})$", ver_str.strip())
        if not match:
            raise ValueError(f"Corrupted version format in sources.nix: '{ver_str}'")
        semver = tuple(int(x) for x in match.group(1).split("."))
        return cls(semver=semver, date_str=match.group(2))


class Source(NamedTuple):
    version: Version
    url: str
    sri_hash: str = ""


def extract_balanced_json(text: str, marker: str = "var params") -> str:
    idx = text.find(marker)
    if idx == -1:
        raise RuntimeError(f"Marker '{marker}' not found in response")
    i = text.find("{", idx)
    if i == -1:
        raise RuntimeError("Opening brace '{' not found in response")

    depth = 0
    in_str = False
    esc = False

    for j in range(i, len(text)):
        c = text[j]
        if in_str:
            if esc:
                esc = False
            elif c == "\\":
                esc = True
            elif c == '"':
                in_str = False
            continue
        if c == '"':
            in_str = True
        elif c == "{":
            depth += 1
        elif c == "}":
            depth -= 1
            if depth == 0:
                return text[i : j + 1]

    raise RuntimeError("Unbalanced braces in JSON payload")


def fetch_json_payload(url: str) -> dict:
    res = subprocess.run(
        ["curl", "-sSfL", url],
        check=True,
        stdout=subprocess.PIPE,
        text=True,
        timeout=30,
    )
    return json.loads(extract_balanced_json(res.stdout))


def probe_accessible_url(url: str) -> str:
    """Prefer upstream raw URL; fallback to legacy storage path if raw URL is unreachable."""
    candidates = [url]
    if "/QQNTV2/" in url:
        candidates.append(url.replace("/QQNTV2/", "/QQNT/"))

    for candidate in candidates:
        res = subprocess.run(
            [
                "curl",
                "-sL",
                "-o",
                "/dev/null",
                "-w",
                "%{http_code}",
                "-r",
                "0-0",
                "-H",
                "Referer: https://im.qq.com/",
                "-H",
                "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36",
                candidate,
            ],
            check=False,
            stdout=subprocess.PIPE,
            text=True,
            timeout=10,
        )
        if res.stdout.strip() in ("200", "206"):
            return candidate

    return url


def fetch_sri_hash(url: str) -> str:
    res = subprocess.run(
        [str(SRI_SCRIPT), url],
        check=True,
        stdout=subprocess.PIPE,
        text=True,
    )
    sri_hash = res.stdout.strip()
    if not sri_hash.startswith("sha256-"):
        raise ValueError(f"Invalid SRI hash format: '{sri_hash}' (URL: {url})")
    return sri_hash


def load_current_state() -> dict[str, Source] | None:
    if not SOURCES_NIX.exists():
        return None

    expr = f"import {SOURCES_NIX} {{ fetchurl = x: x; }}"
    res = subprocess.run(
        [
            "nix",
            "eval",
            "--impure",
            "--extra-experimental-features",
            "nix-command",
            "--expr",
            expr,
            "--json",
        ],
        check=False,
        capture_output=True,
        text=True,
        timeout=30,
    )
    if res.returncode != 0:
        return None

    try:
        data = json.loads(res.stdout)
        return {
            platform: Source(
                version=Version.from_exact_str(data[platform]["version"]),
                url=data[platform]["src"]["url"],
                sri_hash=data[platform]["src"]["hash"],
            )
            for platform in PLATFORM_KEYS
        }
    except (KeyError, ValueError, json.JSONDecodeError):
        return None


def resolve_source(
    name: str,
    raw_url: str,
    fallback_date: str | None,
    current: Source | None,
) -> Source:
    new_url = probe_accessible_url(raw_url)
    new_version = Version.parse_url(new_url, fallback_date)

    if current:
        # 1. 第一级：比对 Version 是否发生回退
        if new_version < current.version:
            print(
                f"[WARN] {name}: Upstream rollback detected ({new_version.full} < {current.version.full}), keeping current"
            )
            return current

        # 2. 第二级：Version 完全一致
        if new_version == current.version:
            # 第三级：比对 URL
            if new_url == current.url:
                # 第四级：URL 也一致，检查本地 Hash 是否有效存在
                if current.sri_hash and current.sri_hash.startswith("sha256-"):
                    print(f"[SKIP] {name}: Up to date ({current.version.full})")
                    return current
                print(f"[INFO] {name}: Hash missing or invalid, fetching...")
            else:
                print(f"[INFO] {name}: URL changed ({current.url} -> {new_url})")
        else:
            print(
                f"[INFO] {name}: Version changed ({current.version.full} -> {new_version.full})"
            )
    else:
        print(f"[INFO] {name}: Initial fetch ({new_version.full})")

    # 仅在确定需要更新时发起真实网络下载
    new_sri_hash = fetch_sri_hash(new_url)
    return Source(
        version=new_version,
        url=new_url,
        sri_hash=new_sri_hash,
    )


def render_sources_nix(resolved: dict[str, Source]) -> str:
    today_str = datetime.now(tz=timezone.utc).date().isoformat()
    darwin = resolved["aarch64-darwin"]
    linux_arm = resolved["aarch64-linux"]
    linux_x64 = resolved["x86_64-linux"]

    return f"""# Generated by ./update.sh - do not update manually!
# Last updated: {today_str}
{{ fetchurl }}:
let
  any-darwin = {{
    version = "{darwin.version.full}";
    src = fetchurl {{
      url = "{darwin.url}";
      hash = "{darwin.sri_hash}";
    }};
  }};
in
{{
  aarch64-darwin = any-darwin;
  x86_64-darwin = any-darwin;

  aarch64-linux = {{
    version = "{linux_arm.version.full}";
    src = fetchurl {{
      url = "{linux_arm.url}";
      hash = "{linux_arm.sri_hash}";
    }};
  }};

  x86_64-linux = {{
    version = "{linux_x64.version.full}";
    src = fetchurl {{
      url = "{linux_x64.url}";
      hash = "{linux_x64.sri_hash}";
    }};
  }};
}}
"""


def main():
    darwin_payload = fetch_json_payload(
        "https://cdn-go.cn/qq-web/im.qq.com_new/latest/rainbow/macOSConfig.js"
    )
    linux_payload = fetch_json_payload(
        "https://cdn-go.cn/qq-web/im.qq.com_new/latest/rainbow/linuxConfig.js"
    )

    current = load_current_state() or {}

    resolved = {
        "aarch64-darwin": resolve_source(
            "macOS universal",
            darwin_payload["downloadUrl"],
            darwin_payload.get("updateDate"),
            current.get("aarch64-darwin"),
        ),
        "aarch64-linux": resolve_source(
            "Linux aarch64",
            linux_payload["armDownloadUrl"]["deb"],
            linux_payload.get("updateDate"),
            current.get("aarch64-linux"),
        ),
        "x86_64-linux": resolve_source(
            "Linux x86_64",
            linux_payload["x64DownloadUrl"]["deb"],
            linux_payload.get("updateDate"),
            current.get("x86_64-linux"),
        ),
    }

    if current and resolved == current:
        print("\n[OK] No changes detected across all platforms")
        sys.exit(0)

    SOURCES_NIX.write_text(render_sources_nix(resolved))
    print("\n[OK] sources.nix updated successfully")


if __name__ == "__main__":
    main()
