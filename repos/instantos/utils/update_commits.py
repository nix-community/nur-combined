#!/usr/bin/env python3
"""Update hashes in *.nix files for fetchFromGitHub commands.

The variable GITHUB_TOKEN is required to interact with the github API.
Tokens can be created in Github's "Developer Settings" under 
"Personal Access Tokens".

A comment "# branch: <specifier>" in the nix file specifies the branch
to get the commit hash of the update.

Usage:
    {__file__} [options] [file|directory]...

Options:
    -h  --help   Print this helptext
"""

import sys, os, shutil, tempfile
import re, json, logging
import os.path
from pathlib import Path as P

import requests
from nix_prefetch_github import nix_prefetch_github

fetch_rex = re.compile(
     # Find fetchFromGitHub lines in nix expressions (in lieu of a Nix AST)
    r"""
        fetchFromGitHub\s+{\s*(
          (\#[^\S\n\r]*branch:[^\S\n\r]*(?P<branch>[\w-]+)\s*\n\s* )|
          (\#[^\S\n\r].*$\s*)|          # allow but ignore other comments
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

def handle_match(match, commit, text):
    fdict = nix_prefetch_github(
        match["owner"], match["repo"], rev=commit,
        prefetch=False, fetch_submodules=match["fetchSubmodules"] or False
    )
    logging.debug(fdict)

    # Dangerous if same sha or commit is used in other context in the same fale
    text = text.replace(match["fullrev"],    f'rev = "{fdict["rev"]}"')
    text = text.replace(match["fullsha256"], f'sha256 = "{fdict["sha256"]}"')
    return text


def github_request(match, auth=None):
    match["branch"] = match["branch"] or "master"
    auth = auth or dict(Authorization="token " + os.getenv("GITHUB_TOKEN"))

    resp = requests.get(
        "https://api.github.com/repos/{owner}/{repo}/branches/{branch}".format(**match),
        headers=auth
    )

    data = resp.json()
    try:
        return data["commit"]["sha"]
    except KeyError:
        if "rate limit exceeded" in resp.reason:
            raise SystemExit(f"Github: API {resp.reason} (see: {data['documentation_url']})")
        logging.exception(
            "Cannot determine commit (%s)[%s]:\n%s\n%s", 
            resp.reason, branch, match.group(), data
        );
        return {}


def print_only(file_, _):
    text = file_.read_text()
    if any(fetch_rex.finditer(text)):
        print(file_)


def process_file(file_, backup):
    text = file_.read_text()
    update = False

    for match in filter(None, fetch_rex.finditer(text)):
        match = match.groupdict()
        commit = github_request(match)
        if not commit:
            continue

        ident = "{owner}/{repo}".format(**match)
        if match["rev"] == commit:
            sys.stderr.write(f"{ident} in '{file_}' is up to date.\n")
            continue

        sys.stderr.write( f"{ident} in '{file_}' needs updating.\n  old: {match['rev']}\n  new: {commit}\n\n")
        text = handle_match(match, commit, text)
        update = True

    if update:
        replace_with_backup(file_, backup, text)


def replace_with_backup(file_, backup, text):
    backup_path = P(backup).joinpath(file_)
    os.makedirs(os.path.dirname(backup_path), exist_ok=True)
    shutil.copy2(str(file_), str(backup_path))
    sys.stderr.write(f"Backup of '{str(file_)}' in '{backup_path}'\n")
    file_.write_text(text)


def walk_dirs(dirs=None, processor=process_file):
    if not dirs:
        dirs = ["./"]

    backup = tempfile.mkdtemp(prefix="nix_hash_bak")

    for dir_ in dirs:
        for file_ in P(dir_).rglob("*.nix"):
            if file_.is_file():
                processor(file_, backup)


### COMMAND LINE HANDLING

def main(args=None):
    args = args or sys.argv[1:]

    if any(x in args for x in ['-h', '--help', '-?', 'help']):
        sys.stderr.write(__doc__.format(**globals()))
        return 0

    verb = ['-v', '--verbose']
    if any(x in args for x in verb):
        logging.basicConfig(level=logging.DEBUG)
        args = [x for x in args if args not in verb]

    processor = process_file
    if "--print-only" in args:
        processor = print_only
        args = [x for x in args if x != "--print-only"]

    walk_dirs(args, processor=processor)
    return 0


if __name__ == "__main__":
    sys.exit( main() )

