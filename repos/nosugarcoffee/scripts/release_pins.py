"""Bump every pkgs/*/pin.json to its upstream's latest release."""

from __future__ import annotations

import json
import os
import re
import subprocess
import sys
import urllib.request
from collections.abc import Callable
from dataclasses import dataclass, replace
from pathlib import Path

HttpGetJson = Callable[[str], object]
Prefetch = Callable[[str], str]

PLACEHOLDER = re.compile(r"\{(\w+)\}")


class PinError(Exception):
    def __init__(self, message: str, summaries: list[str] | None = None) -> None:
        super().__init__(message)
        self.summaries = list(summaries or [])


@dataclass(frozen=True)
class GithubSource:
    repo: str
    asset: str | None


@dataclass(frozen=True)
class JetbrainsSource:
    code: str


@dataclass(frozen=True)
class UnversionedUrlSource:
    pass


Source = GithubSource | JetbrainsSource | UnversionedUrlSource


@dataclass(frozen=True)
class Pin:
    source: Source
    version: str
    vars: dict[str, str]
    url: str
    arch: dict[str, str] | None
    hash: dict[str, str]


@dataclass(frozen=True)
class Release:
    version: str
    vars: dict[str, str]


@dataclass(frozen=True)
class Bump:
    pin: Pin
    summary: str


def parse_pin(raw: dict[str, object], where: str) -> Pin:
    source_raw = _expect(raw, "source", dict, where)
    kind = _expect(source_raw, "type", str, where)
    source: Source
    if kind == "github":
        asset = source_raw.get("asset")
        if asset is not None and not isinstance(asset, str):
            raise PinError(f"{where}: source.asset must be a string")
        source = GithubSource(repo=_expect(source_raw, "repo", str, where), asset=asset)
    elif kind == "jetbrains":
        source = JetbrainsSource(code=_expect(source_raw, "code", str, where))
    elif kind == "unversioned-url":
        source = UnversionedUrlSource()
    else:
        raise PinError(f"{where}: unknown source.type {kind!r}")
    arch = raw.get("arch")
    return Pin(
        source=source,
        version=_expect(raw, "version", str, where),
        vars=_string_map(raw.get("vars", {}), f"{where}: vars"),
        url=_expect(raw, "url", str, where),
        arch=None if arch is None else _string_map(arch, f"{where}: arch"),
        hash=_string_map(_expect(raw, "hash", dict, where), f"{where}: hash"),
    )


def dump_pin(pin: Pin) -> str:
    source: dict[str, str]
    if isinstance(pin.source, GithubSource):
        source = {"type": "github", "repo": pin.source.repo}
        if pin.source.asset is not None:
            source["asset"] = pin.source.asset
    elif isinstance(pin.source, JetbrainsSource):
        source = {"type": "jetbrains", "code": pin.source.code}
    else:
        source = {"type": "unversioned-url"}
    doc: dict[str, object] = {"source": source, "version": pin.version}
    if pin.vars:
        doc["vars"] = pin.vars
    doc["url"] = pin.url
    if pin.arch is not None:
        doc["arch"] = pin.arch
    doc["hash"] = pin.hash
    return json.dumps(doc, indent=2) + "\n"


def render_url(pin: Pin, system: str) -> str:
    values = {**pin.vars, "version": pin.version}
    if pin.arch is not None:
        values["arch"] = pin.arch[system]
    url = PLACEHOLDER.sub(lambda m: values.get(m.group(1), m.group(0)), pin.url)
    unresolved = PLACEHOLDER.findall(url)
    if unresolved:
        raise PinError(f"url {pin.url!r} has no value for {unresolved}")
    return url


def latest_release(pin: Pin, http_get_json: HttpGetJson) -> Release:
    source = pin.source
    if isinstance(source, UnversionedUrlSource):
        return Release(version=pin.version, vars=pin.vars)
    if isinstance(source, JetbrainsSource):
        products = http_get_json(f"https://data.services.jetbrains.com/products?code={source.code}")
        if not isinstance(products, list) or not products:
            raise PinError(f"JetBrains returned no product for code {source.code}")
        return Release(version=products[0]["releases"][0]["build"], vars={})
    release = http_get_json(f"https://api.github.com/repos/{source.repo}/releases/latest")
    if not isinstance(release, dict):
        raise PinError(f"{source.repo}: unexpected latest-release payload")
    version = str(release["tag_name"]).removeprefix("v")
    if source.asset is None:
        return Release(version=version, vars={})
    pattern = re.compile(source.asset.replace("{version}", re.escape(version)))
    matches = [m for m in (pattern.match(a["name"]) for a in release["assets"]) if m]
    if len(matches) != 1:
        raise PinError(f"{source.repo} {version}: expected one asset matching {source.asset}, found {len(matches)}")
    return Release(version=version, vars=matches[0].groupdict())


def bump_pin(name: str, pin: Pin, release: Release, prefetch: Prefetch) -> Bump | None:
    candidate = replace(pin, version=release.version, vars=release.vars)
    unversioned = isinstance(pin.source, UnversionedUrlSource)
    if not unversioned and candidate == pin:
        return None
    hashes = {system: prefetch(render_url(candidate, system)) for system in pin.hash}
    if unversioned and hashes == pin.hash:
        return None
    bumped = replace(candidate, hash=hashes)
    if unversioned:
        return Bump(
            pin=bumped,
            summary=f"- `{name}`: upstream republished at its unversioned URL; hashes updated, "
            f"version label `{pin.version}` left as is.",
        )
    return Bump(pin=bumped, summary=f"- `{name}`: {_label(pin)} -> {_label(bumped)}")


def bump_all(pkgs_dir: Path, http_get_json: HttpGetJson, prefetch: Prefetch) -> list[str]:
    summaries: list[str] = []
    errors: list[str] = []
    for pin_file in sorted(pkgs_dir.glob("*/pin.json")):
        name = pin_file.parent.name
        try:
            pin = parse_pin(json.loads(pin_file.read_text()), str(pin_file))
            bump = bump_pin(name, pin, latest_release(pin, http_get_json), prefetch)
            if bump is not None:
                pin_file.write_text(dump_pin(bump.pin))
                summaries.append(bump.summary)
        except Exception as exc:  # noqa: BLE001 -- one broken upstream must not stop the rest
            errors.append(f"`{name}`: {exc}")
    if errors:
        raise PinError(
            "failed to bump {n} pin(s):\n{details}".format(
                n=len(errors),
                details="\n".join(f"- {error}" for error in errors),
            ),
            summaries,
        )
    return summaries


def http_get_json(url: str) -> object:
    request = urllib.request.Request(url, headers={"Accept": "application/json", "User-Agent": "nur-packages-release-pins"})
    token = os.environ.get("GH_TOKEN")
    if token and url.startswith("https://api.github.com/"):
        request.add_header("Authorization", f"Bearer {token}")
    with urllib.request.urlopen(request, timeout=60) as response:
        return json.load(response)


def nix_prefetch(url: str) -> str:
    result = subprocess.run(
        ["nix", "store", "prefetch-file", "--json", url],
        check=True,
        capture_output=True,
        text=True,
    )
    return json.loads(result.stdout)["hash"]


def write_step_output(summaries: list[str], output: Path | None) -> None:
    text = f"changed={'true' if summaries else 'false'}\nsummary<<SUMMARY_EOF\n" + "\n".join(summaries) + "\nSUMMARY_EOF\n"
    if output is None:
        sys.stdout.write(text)
    else:
        with output.open("a") as handle:
            handle.write(text)


def run(pkgs_dir: Path, http_get_json: HttpGetJson, prefetch: Prefetch) -> int:
    summaries: list[str] = []
    exit_code = 0
    try:
        summaries = bump_all(pkgs_dir, http_get_json, prefetch)
    except PinError as exc:
        summaries = exc.summaries
        print(f"error: {exc}", file=sys.stderr)
        exit_code = 1
    github_output = os.environ.get("GITHUB_OUTPUT")
    write_step_output(summaries, Path(github_output) if github_output else None)
    return exit_code


def main() -> None:
    raise SystemExit(run(Path("pkgs"), http_get_json, nix_prefetch))


def _label(pin: Pin) -> str:
    extras = "".join(f" ({key} {value})" for key, value in sorted(pin.vars.items()))
    return f"{pin.version}{extras}"


def _expect(doc: dict[str, object], key: str, kind: type, where: str):
    value = doc.get(key)
    if not isinstance(value, kind):
        raise PinError(f"{where}: {key} must be a {kind.__name__}")
    return value


def _string_map(value: object, where: str) -> dict[str, str]:
    if not isinstance(value, dict) or not all(isinstance(k, str) and isinstance(v, str) for k, v in value.items()):
        raise PinError(f"{where} must map strings to strings")
    return dict(value)


if __name__ == "__main__":
    main()
