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
from xml.etree import ElementTree

HttpGet = Callable[[str], str]
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
    # When set, follow the newest release whose tag starts with this prefix
    # (prereleases included, drafts skipped) instead of /releases/latest.
    # A monorepo's latest stable tag is often a different component, and a
    # prefix such as "cua-driver-rs-v" does not match nightly tags.
    tag_prefix: str | None = None


@dataclass(frozen=True)
class ExtraFile:
    """A versioned download that is not one of the per-system archives."""

    url: str
    hash: str


@dataclass(frozen=True)
class JetbrainsSource:
    code: str


@dataclass(frozen=True)
class UnversionedUrlSource:
    pass


@dataclass(frozen=True)
class RssSource:
    """A release feed whose item titles carry the version, e.g. "1Password CLI 2.41.1"."""

    feed: str
    title: str


Source = GithubSource | JetbrainsSource | UnversionedUrlSource | RssSource


@dataclass(frozen=True)
class Pin:
    source: Source
    version: str
    vars: dict[str, str]
    url: str
    arch: dict[str, str] | None
    hash: dict[str, str]
    files: dict[str, ExtraFile]


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
        tag_prefix = source_raw.get("tagPrefix")
        if tag_prefix is not None and not isinstance(tag_prefix, str):
            raise PinError(f"{where}: source.tagPrefix must be a string")
        if tag_prefix == "":
            raise PinError(f"{where}: source.tagPrefix must not be empty")
        source = GithubSource(
            repo=_expect(source_raw, "repo", str, where),
            asset=asset,
            tag_prefix=tag_prefix,
        )
    elif kind == "jetbrains":
        source = JetbrainsSource(code=_expect(source_raw, "code", str, where))
    elif kind == "unversioned-url":
        source = UnversionedUrlSource()
    elif kind == "rss":
        title = _expect(source_raw, "title", str, where)
        if "version" not in re.compile(title).groupindex:
            raise PinError(f"{where}: source.title needs a (?P<version>...) group")
        source = RssSource(feed=_expect(source_raw, "feed", str, where), title=title)
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
        files=_parse_files(raw.get("files", {}), f"{where}: files"),
    )


def dump_pin(pin: Pin) -> str:
    source: dict[str, str]
    if isinstance(pin.source, GithubSource):
        source = {"type": "github", "repo": pin.source.repo}
        if pin.source.asset is not None:
            source["asset"] = pin.source.asset
        if pin.source.tag_prefix is not None:
            source["tagPrefix"] = pin.source.tag_prefix
    elif isinstance(pin.source, JetbrainsSource):
        source = {"type": "jetbrains", "code": pin.source.code}
    elif isinstance(pin.source, RssSource):
        source = {"type": "rss", "feed": pin.source.feed, "title": pin.source.title}
    else:
        source = {"type": "unversioned-url"}
    doc: dict[str, object] = {"source": source, "version": pin.version}
    if pin.vars:
        doc["vars"] = pin.vars
    doc["url"] = pin.url
    if pin.arch is not None:
        doc["arch"] = pin.arch
    doc["hash"] = pin.hash
    if pin.files:
        doc["files"] = {name: {"url": extra.url, "hash": extra.hash} for name, extra in pin.files.items()}
    return json.dumps(doc, indent=2) + "\n"


def render_url(pin: Pin, system: str) -> str:
    return _render(pin, pin.url, system)


def render_file_url(pin: Pin, name: str) -> str:
    try:
        extra = pin.files[name]
    except KeyError as exc:
        raise PinError(f"no file {name!r}") from exc
    return _render(pin, extra.url, None)


def _render(pin: Pin, template: str, system: str | None) -> str:
    values = {**pin.vars, "version": pin.version}
    if system is not None and pin.arch is not None:
        try:
            values["arch"] = pin.arch[system]
        except KeyError as exc:
            raise PinError(f"no arch entry for {system}") from exc
    url = PLACEHOLDER.sub(lambda m: values.get(m.group(1), m.group(0)), template)
    unresolved = PLACEHOLDER.findall(url)
    if unresolved:
        raise PinError(f"url {template!r} has no value for {unresolved}")
    return url


def latest_release(pin: Pin, http_get: HttpGet) -> Release:
    source = pin.source
    if isinstance(source, UnversionedUrlSource):
        return Release(version=pin.version, vars=pin.vars)
    if isinstance(source, RssSource):
        return Release(version=_newest_feed_version(source, http_get(source.feed)), vars={})
    if isinstance(source, JetbrainsSource):
        products = json.loads(http_get(f"https://data.services.jetbrains.com/products?code={source.code}"))
        if not isinstance(products, list) or not products:
            raise PinError(f"JetBrains returned no product for code {source.code}")
        return Release(version=products[0]["releases"][0]["build"], vars={})
    release = _github_release(source, http_get)
    tag = str(release["tag_name"])
    version = tag.removeprefix(source.tag_prefix) if source.tag_prefix is not None else tag.removeprefix("v")
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
    files = {
        filename: ExtraFile(url=extra.url, hash=prefetch(render_file_url(candidate, filename)))
        for filename, extra in candidate.files.items()
    }
    if unversioned and hashes == pin.hash and files == pin.files:
        return None
    bumped = replace(candidate, hash=hashes, files=files)
    if unversioned:
        return Bump(
            pin=bumped,
            summary=f"- `{name}`: upstream republished at its unversioned URL; hashes updated, "
            f"version label `{pin.version}` left as is.",
        )
    return Bump(pin=bumped, summary=f"- `{name}`: {_label(pin)} -> {_label(bumped)}")


def bump_all(pkgs_dir: Path, http_get: HttpGet, prefetch: Prefetch) -> list[str]:
    summaries: list[str] = []
    errors: list[str] = []
    for pin_file in sorted(pkgs_dir.glob("*/pin.json")):
        name = pin_file.parent.name
        try:
            pin = parse_pin(json.loads(pin_file.read_text()), str(pin_file))
            bump = bump_pin(name, pin, latest_release(pin, http_get), prefetch)
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


def http_get(url: str) -> str:
    request = urllib.request.Request(url, headers={"User-Agent": "nur-packages-release-pins"})
    token = os.environ.get("GH_TOKEN")
    if token and url.startswith("https://api.github.com/"):
        request.add_header("Authorization", f"Bearer {token}")
    with urllib.request.urlopen(request, timeout=60) as response:
        return response.read().decode()


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


def run(pkgs_dir: Path, http_get: HttpGet, prefetch: Prefetch) -> int:
    summaries: list[str] = []
    exit_code = 0
    try:
        summaries = bump_all(pkgs_dir, http_get, prefetch)
    except PinError as exc:
        summaries = exc.summaries
        print(f"error: {exc}", file=sys.stderr)
        exit_code = 1
    github_output = os.environ.get("GITHUB_OUTPUT")
    write_step_output(summaries, Path(github_output) if github_output else None)
    return exit_code


def main() -> None:
    raise SystemExit(run(Path("pkgs"), http_get, nix_prefetch))


_MAX_RELEASE_PAGES = 10


def _releases_page(repo: str, page: int) -> str:
    return f"https://api.github.com/repos/{repo}/releases?per_page=100&page={page}"


def _github_release(source: GithubSource, http_get: HttpGet) -> dict[str, object]:
    if source.tag_prefix is None:
        release = json.loads(http_get(f"https://api.github.com/repos/{source.repo}/releases/latest"))
        if not isinstance(release, dict):
            raise PinError(f"{source.repo}: unexpected latest-release payload")
        return release
    for page in range(1, _MAX_RELEASE_PAGES + 1):
        payload = json.loads(http_get(_releases_page(source.repo, page)))
        if not isinstance(payload, list):
            raise PinError(f"{source.repo}: unexpected releases payload")
        for release in payload:
            if not isinstance(release, dict) or release.get("draft") is True:
                continue
            tag = release.get("tag_name")
            if isinstance(tag, str) and tag.startswith(source.tag_prefix):
                return release
        if len(payload) < 100:
            break
    raise PinError(f"{source.repo}: no release tagged {source.tag_prefix}*")


def _newest_feed_version(source: RssSource, feed_xml: str) -> str:
    pattern = re.compile(source.title)
    titles = [item.findtext("title", "") for item in ElementTree.fromstring(feed_xml).iter("item")]
    versions = [m["version"] for m in (pattern.fullmatch(t.strip()) for t in titles) if m]
    if not versions:
        raise PinError(f"{source.feed}: no item title matches {source.title}")
    return max(versions, key=_version_key)


def _version_key(version: str) -> tuple[int, ...]:
    try:
        return tuple(int(part) for part in version.split("."))
    except ValueError as exc:
        raise PinError(f"version {version!r} is not dot-separated numbers") from exc


def _parse_files(value: object, where: str) -> dict[str, ExtraFile]:
    if not isinstance(value, dict):
        raise PinError(f"{where} must map names to {{url, hash}}")
    files: dict[str, ExtraFile] = {}
    for name, spec in value.items():
        spec_where = f"{where}.{name}" if isinstance(name, str) else where
        if not isinstance(name, str) or not isinstance(spec, dict):
            raise PinError(f"{where} must map names to {{url, hash}}")
        files[name] = ExtraFile(
            url=_expect(spec, "url", str, spec_where),
            hash=_expect(spec, "hash", str, spec_where),
        )
    return files


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
