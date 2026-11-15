#!/usr/bin/env python3
"""Export browser pins owned by this AliasMode source release."""

import json
import os
from pathlib import Path
import re

root = Path(os.environ["FETCHRIX_SOURCE"])
source = (root / "firefox-install.ts").read_text()


def match(pattern):
    matches = re.findall(pattern, source, re.DOTALL)
    if len(matches) != 1:
        raise ValueError(f"Expected exactly one browser runtime declaration: {pattern}")
    return matches[0]


version = match(r'export const FIREFOX_RUNTIME_VERSION = "([^"]+)";')
release = match(r'const FIREFOX_RUNTIME_RELEASE = `([^`]+)`;')
release = release.replace("${FIREFOX_RUNTIME_VERSION}", version)
if not re.fullmatch(r"[A-Za-z0-9._-]+", release):
    raise ValueError("Unsupported Firefox release template")
base = match(r'const FIREFOX_RELEASE_BASE = `([^`]+)`;')
base = base.replace("${FIREFOX_RUNTIME_RELEASE}", release)
if not base.startswith("https://github.com/aliasmode/aliasmode-firefox/releases/download/") or "${" in base:
    raise ValueError("Unsupported Firefox release origin")
linux = match(r'\{\s*platform: "linux", arch: "x64",(.*?)\}')
fields = dict(re.findall(r'(executablePath|archiveSha256|executableSha256): "([^"]+)"', linux))
if set(fields) != {"executablePath", "archiveSha256", "executableSha256"}:
    raise ValueError("Incomplete Firefox Linux runtime pin")
for field in ("archiveSha256", "executableSha256"):
    if not re.fullmatch(r"[a-f0-9]{64}", fields[field]):
        raise ValueError(f"Invalid Firefox hash: {field}")
archive = match(r'\? `(aliasmode-\$\{FIREFOX_RUNTIME_VERSION\}-lin\.x86_64\.zip)`')
archive = archive.replace("${FIREFOX_RUNTIME_VERSION}", version)
metadata = {
    "firefox": {
        "url": f"{base}/{archive}",
        "version": version,
        "executable": fields["executablePath"],
        "sha256": fields["executableSha256"],
        "archiveSha256": fields["archiveSha256"],
    }
}
source = (root / "aliasmode-chromium.ts").read_text()
chromium_version = match(r'const OWN_VERSION = "([^"]+)";')
chromium_release = match(r'const OWN_RELEASE = "([^"]+)";')
if not all(re.fullmatch(r"[A-Za-z0-9._-]+", value) for value in (chromium_version, chromium_release)):
    raise ValueError("Unsupported Chromium version or release")
variables = {"OWN_VERSION": chromium_version, "OWN_RELEASE": chromium_release}


def expand(template):
    return re.sub(r"\$\{([A-Z_]+)\}", lambda item: variables[item[1]], template)


variables["OWN_RELEASE_URL"] = expand(match(r'const OWN_RELEASE_URL = `([^`]+)`;'))
if not variables["OWN_RELEASE_URL"].startswith("https://github.com/aliasmode/aliasmode-chromium/releases/download/"):
    raise ValueError("Unsupported Chromium release origin")
linux = match(r'const LINUX_BUILD = \{(.*?)\n\};')
fields = dict(re.findall(r'(root|url|dir|executable|archiveSha256|executableSha256): ["`]([^"`]+)["`]', linux))
if set(fields) != {"root", "url", "dir", "executable", "archiveSha256", "executableSha256"}:
    raise ValueError("Incomplete Chromium Linux runtime pin")
for field in ("archiveSha256", "executableSha256"):
    if not re.fullmatch(r"[a-f0-9]{64}", fields[field]):
        raise ValueError(f"Invalid Chromium hash: {field}")
metadata["chromium"] = {
    "url": expand(fields["url"]),
    "version": f"{chromium_version}-{chromium_release}",
    "archiveRoot": expand(fields["root"]),
    "executable": fields["executable"],
    "sha256": fields["executableSha256"],
    "archiveSha256": fields["archiveSha256"],
}
(root / "browser-runtime.json").write_text(json.dumps(metadata, indent=2) + "\n")

# beta.74 joins two diff headers without a newline; leave corrected releases alone.
patch = root / "patches/playwright-core@1.58.2.patch"
original = patch.read_text()
patch.write_text(original.replace("async doGetCookies(urls) {diff --git", "async doGetCookies(urls) {\ndiff --git"))
