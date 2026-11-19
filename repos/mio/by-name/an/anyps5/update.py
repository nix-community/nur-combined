#!/usr/bin/env python3
# Update AnyPS5 to the tip of upstream `main`.
#
# The build copies each git submodule out of its pinned revision, so the main
# source revision and all `3rdparty/*` pins have to move together. The version
# keeps the repo convention `<latest-tag>-unstable-<commit-date>`.
import re
import subprocess
import sys
import tempfile
from pathlib import Path

REPO = "https://github.com/boykopovar/AnyPS5.git"
MAIN_KEY = ("github.com", "boykopovar", "anyps5")

FETCH_BLOCK = re.compile(
    r"(?m)^([ \t]*)(\w+) = fetchFromGitHub \{\n(.*?)\n\1\};", re.DOTALL
)
FETCHZIP_BLOCK = re.compile(
    r"(?m)^([ \t]*)(\w+) = fetchzip \{\n(.*?)\n\1\};", re.DOTALL
)


def run(cmd):
    return subprocess.check_output(cmd, text=True).strip()


def version_key(tag):
    return tuple(int(x) for x in tag.split("."))


def latest_tag():
    out = run(["git", "ls-remote", "--tags", REPO])
    tags = []
    for line in out.splitlines():
        if not line.strip():
            continue
        ref = line.split()[1]
        if not ref.startswith("refs/tags/"):
            continue
        tag = ref[len("refs/tags/"):]
        if re.fullmatch(r"v\d+(\.\d+)*", tag):
            tags.append(tag)
    if not tags:
        raise SystemExit("error: no release tags found upstream")
    return max(tags, key=lambda t: version_key(t.lstrip("v")))


def fetch_rev(repo, rev=None):
    """Shallow-fetch a revision and return (commit, date, gitlink revs)."""
    with tempfile.TemporaryDirectory() as td:
        run(["git", "init", "-q", td])
        run(["git", "-C", td, "remote", "add", "origin", repo])
        run(
            ["git", "-C", td, "fetch", "-q", "--depth=1", "--filter=blob:none", "origin"]
            + ([rev] if rev else ["HEAD"])
        )
        commit = run(["git", "-C", td, "rev-parse", "FETCH_HEAD"])
        date = run(["git", "-C", td, "log", "-1", "--format=%cs", "FETCH_HEAD"])
        try:
            gitmodules = run(["git", "-C", td, "show", "FETCH_HEAD:.gitmodules"])
        except subprocess.CalledProcessError:
            gitmodules = ""
        tree = run(["git", "-C", td, "ls-tree", "-r", "FETCH_HEAD"])

    paths = {}
    current = None
    for line in gitmodules.splitlines():
        line = line.strip()
        if line.startswith("[submodule "):
            current = {}
            continue
        if current is None:
            continue
        key, _, value = line.partition("=")
        key, value = key.strip(), value.strip()
        if key in ("path", "url"):
            current[key] = value
        if current.get("path") and current.get("url"):
            paths[current["path"]] = current["url"]

    revs = {}
    for line in tree.splitlines():
        meta, _, path = line.partition("\t")
        fields = meta.split()
        if len(fields) == 3 and fields[1] == "commit":
            revs[path] = fields[2]

    return commit, date, {paths[p]: revs[p] for p in paths if p in revs}


def normalize_url(url):
    url = url.strip().rstrip("/")
    if url.endswith(".git"):
        url = url[: -len(".git")]
    m = re.match(r"https?://([^/]+)/(.+)$", url)
    if not m:
        return None
    host, rest = m.group(1).lower(), m.group(2)
    parts = rest.split("/")
    return host, parts[0].lower(), parts[-1].lower()


def prefetch(url, unpack):
    cmd = ["nix-prefetch-url"] + (["--unpack"] if unpack else []) + [url]
    raw = run(cmd).splitlines()[-1]
    return run(["nix", "hash", "convert", "--hash-algo", "sha256", "--to", "sri", raw])


def set_attrs(block, values):
    for attr, value in values.items():
        block, n = re.subn(
            rf'(?m)^(\s*{attr}\s*=\s*)"[^"]+"', rf'\g<1>"{value}"', block, count=1
        )
        if n != 1:
            raise SystemExit(f"error: could not update {attr} in {block.splitlines()[0]}")
    return block


def rebuild(indent, name, kind, body):
    return f"{indent}{name} = {kind} {{\n{body}\n{indent}}};"


def main():
    try:
        repo_root = Path(run(["git", "rev-parse", "--show-toplevel"]))
    except subprocess.CalledProcessError:
        repo_root = Path(__file__).resolve().parents[3]
    pkg_nix = repo_root / "by-name/an/anyps5/package.nix"
    content = pkg_nix.read_text(encoding="utf-8")

    rev, date, pinned = fetch_rev(REPO)
    submodules = {
        normalize_url(url): commit for url, commit in pinned.items() if normalize_url(url)
    }
    # The main source block follows `main` itself, not a submodule pin.
    submodules[MAIN_KEY] = rev

    base = latest_tag().lstrip("v")
    version = f"{base}-unstable-{date}"

    old_version = re.search(r'(?m)^\s*version = "([^"]+)";', content).group(1)
    print(f"Source:  {rev} ({date}), base tag {base}")
    print(f"Version: {old_version} -> {version}")

    if old_version != version:
        content, n = re.subn(
            r'(?m)^(\s*version = )"[^"]+"', rf'\g<1>"{version}"', content, count=1
        )
        if n != 1:
            raise SystemExit("error: could not update version in package.nix")

    replacements = []
    for m in FETCH_BLOCK.finditer(content):
        indent, name, body = m.group(1), m.group(2), m.group(3)
        owner = re.search(r'owner = "([^"]+)"', body).group(1)
        repo = re.search(r'repo = "([^"]+)"', body).group(1)
        old_rev = re.search(r'rev = "([^"]+)"', body).group(1)
        key = ("github.com", owner.lower(), repo.lower())
        new_rev = submodules.get(key)
        if not new_rev and key == ("github.com", "mbed-tls", "mbedtls-framework"):
            # The framework revision is pinned by the mbedtls submodule itself.
            mbedtls = submodules.get(("github.com", "mbed-tls", "mbedtls"))
            if mbedtls:
                _, _, nested = fetch_rev("https://github.com/Mbed-TLS/mbedtls.git", mbedtls)
                new_rev = nested.get("https://github.com/Mbed-TLS/mbedtls-framework")
        if not new_rev:
            print(f"warning: no upstream submodule for {owner}/{repo}", file=sys.stderr)
            continue
        if new_rev == old_rev:
            continue
        print(f"  {name}: {old_rev} -> {new_rev}")
        new_hash = prefetch(f"https://github.com/{owner}/{repo}/archive/{new_rev}.tar.gz", True)
        updated = rebuild(
            indent, name, "fetchFromGitHub", set_attrs(body, {"rev": new_rev, "hash": new_hash})
        )
        replacements.append((m.start(), m.end(), updated))

    for m in FETCHZIP_BLOCK.finditer(content):
        indent, name, body = m.group(1), m.group(2), m.group(3)
        url = re.search(r'url = "([^"]+)"', body).group(1)
        archive = re.search(r"/-/archive/([^/]+)/", url)
        if not archive:
            continue
        key = normalize_url(url.split("/-/archive/")[0])
        new_rev = submodules.get(key) if key else None
        if not new_rev or archive.group(1) == new_rev:
            continue
        new_url = url.replace(archive.group(1), new_rev)
        print(f"  {name}: {archive.group(1)} -> {new_rev}")
        new_hash = prefetch(new_url, True)
        updated = rebuild(
            indent, name, "fetchzip", set_attrs(body, {"url": new_url, "hash": new_hash})
        )
        replacements.append((m.start(), m.end(), updated))

    # The prebuilt ffmpeg asset is named after the ffmpeg-core short revision.
    core = re.search(r'ffmpegCore = fetchFromGitHub \{\n.*?rev = "([^"]+)"', content, re.DOTALL)
    for m in FETCHZIP_BLOCK.finditer(content):
        if m.group(2) != "ffmpegPrebuilt":
            continue
        body = m.group(3)
        url = re.search(r'url = "([^"]+)"', body).group(1)
        current = re.search(r"/download/([^/]+)/", url)
        if core and current and current.group(1) != core.group(1)[:12]:
            want = core.group(1)[:12]
            new_url = url.replace(current.group(1), want)
            print(f"  ffmpegPrebuilt: {current.group(1)} -> {want}")
            new_hash = prefetch(new_url, True)
            updated = rebuild(
                m.group(1),
                "ffmpegPrebuilt",
                "fetchzip",
                set_attrs(body, {"url": new_url, "hash": new_hash}),
            )
            replacements.append((m.start(), m.end(), updated))

    if replacements:
        for start, end, updated in reversed(replacements):
            content = content[:start] + updated + content[end:]
        pkg_nix.write_text(content, encoding="utf-8")
        print(f"Successfully updated anyps5 to {version} ({len(replacements)} pins changed)")
    else:
        print("anyps5 is already up to date.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
