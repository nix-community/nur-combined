#!/usr/bin/env python3
"""Update hashes in nix files for fetchFromGitHub commands.

REQUIRES GITHUB_TOKEN ENVIRONMENT VARIABLE!
The variable GITHUB_TOKEN is required to interact with the github API.
Tokens can be created in the "Developer Settings" under "Personal Access Tokens".

A comment "# branch: <specifier>" specifies the branch or tag to update in
the nix file.

Usage:
    {} [options] [file|directory]...

Options:
    -h  --help   Print this helptext
"""

import sys, os, shutil, tempfile
import re, json, logging
import os.path
from pathlib import Path as P

import requests
from nix_prefetch_github import nix_prefetch_github

rex_fetch = re.compile(
     # Find fetchFromGitHub lines in nix expressions (in lieu of a Nix AST)
     # ToDo: account for possible comments
    r"""
        fetchFromGitHub\s+{\s*(
          (\#[^\S\n\r]*branch:[^\S\n\r]*(?P<branch>[\w-]+)\s*\n\s* )|
          ((?P<fullowner>   owner  \s* = \s* "(?P<owner>[\w-]+)")             \s* ; \s* )|
          ((?P<fullrepo>    repo   \s* = \s* "(?P<repo>[\w-]+)")              \s* ; \s* )|
          ((?P<fullname>    name   \s* = \s* "(?P<name>[\w=]+)")              \s* ; \s* )|
          ((?P<fullmodules> fetchSubmodules \s* = \s* "(?P<fetchSubmodules>[\w=]+)")  \s* ; \s* )|
          ((?P<fullrev>     rev    \s* = \s* "(?P<rev>[\w-]+)")               \s* ; \s* )|
          ((?P<fullsha256>  sha256 \s* = \s* "(?P<sha256>[\w=]+)")            \s* ; \s* )
        )+}
    """,
    re.MULTILINE | re.VERBOSE
)

def process_file(fl, backup):
    text = fl.read_text()
    for f in filter(None, rex_fetch.finditer(text)):
        branch = f["branch"] or "master"  # or tag...
        ident = f"{f['owner']}/{f['repo']}"
        resp = requests.get(f"https://api.github.com/repos/{ident}/branches/{branch}", headers=dict(Authorization="token " + os.getenv("GITHUB_TOKEN")))

        data = resp.json()
        try:
            commit = data["commit"]["sha"]
        except KeyError:
            if "rate limit exceeded" in resp.reason:
                raise SystemExit(f"Github: API {resp.reason} (see: {data['documentation_url']})")
            logging.exception(
                "Cannot determine commit for '%s' (%s)[%s]:\n%s\n%s", 
                fl.as_posix(), resp.reason, branch, f.group(), data
            );
            continue

        if f["rev"] == commit:
            sys.stderr.write(f"{ident} is up to date.\n")
            continue

        sys.stderr.write(
            f"{ident} needs updating.\n"
            f"  old: {f['rev']}\n"
            f"  new: {commit}\n\n"
        )

        fdict = nix_prefetch_github(
            f["owner"], f["repo"], rev=commit,
            prefetch=False, fetch_submodules=f["fetchSubmodules"] or False
        )
        logging.debug(fdict)

        # Dangerous if same sha or commit are used in same file multiple times
        #+but we do backups... :D
        text = text.replace(f["fullrev"],    f'rev = "{fdict["rev"]}"')
        text = text.replace(f["fullsha256"], f'sha256 = "{fdict["sha256"]}"')
        backup_path = P(backup).joinpath(fl)
        os.makedirs(os.path.dirname(backup_path), exist_ok=True)
        shutil.copy2(str(fl), str(backup_path))
        sys.stderr.write(f"Backup of '{str(fl)}' in '{backup_path}'\n")
        fl.write_text(text)


def walk_dir(dirs=None):
    if not dirs:
        dirs = ["./"]

    backup = tempfile.mkdtemp(prefix="nix_hash_bak")

    for dir_ in dirs:
        for fl in P(dir_).rglob("*.nix"):
            if fl.is_file():
                process_file(fl, backup)


def main(args=None):
    args = args or sys.argv[1:]

    if any(x in args for x in ['-h', '--help', '-?', 'help']):
        sys.stderr.write(__doc__)

    walk_dir(args)
    return 0


if __name__ == "__main__":
    sys.exit( main() )
