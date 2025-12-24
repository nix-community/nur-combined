import argparse
import datetime
import json
import os
import re
import subprocess
from pathlib import Path
from urllib.request import Request, urlopen, urlretrieve

import nima
from nima.expressions import FunctionCall

# --- Constants ---

FORCE_BLACKLIST = [
    Path("./pkgs/by-name/libfprint-focaltech-2808-a658-alt/package.nix"),
    Path("./pkgs/by-name/fprintd/package.nix"),
]


# --- Utility Functions ---


def get_github_info(url: str | None = None, src: FunctionCall | None = None):
    """
    Extracts the owner and repository from a GitHub URL or a fetchFromGitHub src attribute.

    Args:
        url (str, optional): A GitHub URL.
        src (FunctionCall, optional): A Nima FunctionCall object for a fetchFromGitHub expression.

    Raises:
        ValueError: If the URL is not a valid GitHub URL or if neither url nor src is provided.

    Returns:
        tuple[str, str]: A tuple containing the owner and repository name.
    """
    if url:
        check = re.search(r"github\.com/([^/]+)/([^/]+)", url)
        if check:
            owner, repo = check.groups()
        else:
            raise ValueError("Invalid GitHub URL")
    elif src:
        owner = src.argument["owner"].value
        repo = src.argument["repo"].value
    else:
        raise ValueError("Either URL or src must be provided")

    return owner, repo


def get_latest_github_release(owner: str, repo: str) -> str:
    """
    Fetches the latest release tag name from a GitHub repository using the GitHub API.

    Args:
        owner (str): The repository owner.
        repo (str): The repository name.

    Returns:
        str: The tag name of the latest release.
    """
    url = f"https://api.github.com/repos/{owner}/{repo}/releases/latest"
    req = Request(url, headers={})

    try:
        with urlopen(req) as response:
            if response.status == 200:
                data = json.loads(response.read().decode("utf-8"))
                return data.get("tag_name")
            else:
                print(f"Error: Received status code {response.status}")
                exit()
    except Exception as e:
        print(f"An unexpected error occurred: {e}")
        exit()


def fetch_cargo_lock(url: str, path: Path):
    """
    Downloads a Cargo.lock file from a given URL and saves it to the specified path.

    Args:
        url (str): The URL to download the Cargo.lock from.
        path (Path): The directory path to save the Cargo.lock file in.
    """
    urlretrieve(url, path / "Cargo.lock")


# --- Path and Package Discovery ---


def get_all_drv_paths(path: Path) -> list[Path]:
    """
    Walks the path to find all 'package.nix' files, excluding blacklisted ones.

    Returns:
        list[Path]: A sorted list of Path objects for each derivation file.
    """
    if path.is_file():
        return [path]

    elif path.is_dir():
        all_files = []
        for dirpath, dirnames, filenames in os.walk(path):
            for filename in filenames:
                if filename != "package.nix":
                    continue
                full_path = os.path.join(dirpath, filename)
                all_files.append(full_path)

        drv_paths = list(map(Path, sorted(all_files)))
        for path in FORCE_BLACKLIST:
            if path in drv_paths:
                drv_paths.remove(path)

        return drv_paths

    else:
        raise ValueError(
            "Must be a path to a derivation or a directory containing derivations."
        )


# --- Core Update Logic ---


def update_url_src(attrs, scoped_vars, fixed_attrs=[]):
    """
    Updates a fetchurl source by prefetching the file and updating the hash.

    If the URL is a GitHub release URL, it will also attempt to update the
    version to the latest release tag. It handles URLs with interpolated Nix variables.

    Args:
        attrs (FunctionCall): The Nima FunctionCall object for the derivation.
        scoped_vars (LetExpression): The scoped variables from a let expression, if any.
        fixed_attrs (list, optional): A list to track attributes that should not be modified. Defaults to [].
    """
    src = attrs.argument["src"]

    url = src.argument["url"].value
    vars = re.findall(r"(\$\{\S+?\})", url)
    if len(vars) > 0:
        fixed_attrs.append("src")
        for var in vars:
            url = url.replace(var, attrs.argument[var[2:-1]].value)

    check_github_release_url = re.search(
        r"github\.com/[^/]+/[^/]+/releases/download", url
    )
    if check_github_release_url:
        owner, repo = get_github_info(url)
        version = get_latest_github_release(owner, repo)
        attrs.argument["version"].value = (
            version if version[0].lower() != "v" else version[1:]
        )

    result = json.loads(
        subprocess.run(
            [
                "nix",
                "store",
                "prefetch-file",
                "--json",
                url,
            ],
            capture_output=True,
            text=True,
            check=True,
        ).stdout
    )

    src.argument["hash"].value = result["hash"]


def update_github_src(attrs, scoped_vars):
    """
    Updates a fetchFromGitHub source by fetching the latest commit information.

    It runs `nix-prefetch-git` to get the latest revision and hash, then updates
    the `rev`, `hash`, and `version` attributes in the derivation.

    Args:
        attrs (FunctionCall): The Nima FunctionCall object for the derivation.
        scoped_vars (LetExpression): The scoped variables from a let expression, if any.

    Returns:
        dict: The result from `nix-prefetch-git`, containing rev, hash, etc.
    """
    src = attrs.argument["src"]

    owner = src.argument["owner"].value
    repo = src.argument["repo"].value

    try:
        rev = src.argument["rev"].value
    except KeyError:
        rev = None

    cmd = [
        "nix-prefetch-git",
        "--url",
        f"https://github.com/{owner}/{repo}",
        "--quiet",
    ]

    try:
        dir_identifier = src.argument["sparseCheckout"].value[0]
    except KeyError:
        pass
    else:
        try:
            dir = dir_identifier.value
        except AttributeError:
            var = dir_identifier.name
            dir = attrs.argument[var].value
        finally:
            cmd.extend(["--sparse-checkout", dir])

    result = json.loads(
        subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            check=True,
        ).stdout
    )

    date = str(datetime.datetime.fromisoformat(result["date"]).date())
    attrs.argument["version"].value = f"unstable-{date}"

    if rev:
        src.argument["rev"].value = result["rev"]
    src.argument["hash"].value = result["hash"]

    return result


def get_updater_args(attrs):
    """
    Parses updater arguments from the derivation's `passthru.yanseu` attribute set.

    Defaults to `{"version": "unstable"}` if not present.

    Args:
        attrs (FunctionCall): The Nima FunctionCall object for the derivation.

    Returns:
        dict: A dictionary of updater arguments.
    """
    default_updater_args = {
        "version": "unstable",
    }

    try:
        updater_args_raw = attrs.argument["passthru.yanseu"].values
    except KeyError:
        updater_args = default_updater_args
    else:
        updater_args = {
            updater_args_raw[i].name: updater_args_raw[i].value.value
            for i in range(len(updater_args_raw))
        }
        for key, value in default_updater_args.items():
            if key not in updater_args:
                updater_args[key] = value

    assert updater_args["version"] in {"stable", "unstable", "pinned"}

    return updater_args


def update_drv(drv_path: Path):
    """
    Updates a single Nix derivation file based on its fetcher type.

    This function parses the derivation file, determines the fetcher (`fetchurl`,
    `fetchFromGitHub`, etc.), and calls the appropriate update function.
    It also handles fetching `Cargo.lock` files if needed.

    Args:
        drv_path (Path): The path to the derivation file (e.g., 'package.nix').
    """
    code = nima.parse(drv_path.read_bytes())
    attrs = code.value[0].output

    scoped_vars = None
    # Check if the derivation is within a let expression
    if attrs.tree_sitter_types == {"let_expression"}:
        scoped_vars = attrs.local_variables
        attrs = attrs.value

    pname = attrs.argument["pname"].value
    src = attrs.argument["src"]

    updater_args = get_updater_args(attrs)
    if updater_args["version"] == "pinned":
        print(f"Skipped {pname} ...")
        return

    print(f"Updating {pname}...")

    fetcher = src.name
    if fetcher == "fetchurl":
        update_url_src(attrs, scoped_vars)

    elif fetcher == "fetchFromGitHub":
        git_head_info = update_github_src(attrs, scoped_vars)

        try:
            attrs.argument["cargoLock.lockFile"]
        except KeyError:
            pass
        else:
            owner, repo = get_github_info(src=src)
            rev = git_head_info["rev"]
            fetch_cargo_lock(
                f"https://raw.githubusercontent.com/{owner}/{repo}/{rev}/Cargo.lock",
                drv_path.parent,
            )

    drv_path.write_text(code.rebuild())


# --- Main entrypoint ---


def main():
    """
    Main entry point for the script.

    Either updates a single derivation file provided as a command-line argument,
    or if none is provided, it updates all derivation files found in PKGS_DIR.
    """
    parser = argparse.ArgumentParser(prog="update")
    parser.add_argument(
        "PATH",
        type=Path,
        help="Path to a single derivation file or a directory containing derivation files.",
    )
    args = parser.parse_args()

    drv_paths = get_all_drv_paths(args.PATH)
    for drv_path in drv_paths:
        update_drv(drv_path)

    return


if __name__ == "__main__":
    main()
