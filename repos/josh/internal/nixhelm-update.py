import os
import re
import subprocess
import sys
import tempfile
import shutil

import click
import yaml

GIT_PATH = "@git@"
HELM_PATH = "@helm@"
NIX_HASH_PATH = "@nix-hash@"
NIX_PATH = "@nix@"


@click.command()
@click.option("--url", required=True)
@click.option("--chart", required=False)
@click.option("--nix-name", envvar="UPDATE_NIX_NAME")
@click.option("--nix-pname", envvar="UPDATE_NIX_PNAME")
@click.option("--nix-old-version", envvar="UPDATE_NIX_OLD_VERSION")
@click.option("--nix-attr-path", envvar="UPDATE_NIX_ATTR_PATH")
@click.option("--filename")
@click.option("--commit", is_flag=True)
@click.option("--dry-run", is_flag=True)
def main(
    url: str,
    chart: str,
    nix_name: str | None,
    nix_pname: str | None,
    nix_old_version: str | None,
    nix_attr_path: str | None,
    filename: str | None,
    commit: bool,
    dry_run: bool,
):
    if not nix_attr_path and chart:
        nix_attr_path = f"{chart}-chart"

    if nix_attr_path and not filename:
        filename = nix_attr_filename(attr_path=nix_attr_path)

    if not filename:
        raise click.UsageError("filename is required")

    with open(filename, "r") as f:
        content = f.read()

    if not nix_pname:
        nix_pname = os.path.basename(filename).removesuffix(".nix")

    if url.startswith("oci://"):
        chart_path = helm_pull_oci(url=url)
    elif chart and url:
        chart_path = helm_pull(chart=chart, repo=url)
    else:
        raise click.UsageError("chart name is required")

    with open(f"{chart_path}/Chart.yaml", "r") as f:
        chart_data = yaml.safe_load(f)
    version = chart_data["version"].lstrip("v")

    sha256 = nix_hash(chart_path)

    shutil.rmtree(chart_path)

    content = re.sub(
        r'(^\s+version = ")(.*)(")',
        lambda m: m.group(1) + version + m.group(3),
        content,
        flags=re.MULTILINE,
    )

    content = re.sub(
        r'(^\s+sha256 = ")(.*)(")',
        lambda m: m.group(1) + sha256 + m.group(3),
        content,
        flags=re.MULTILINE,
    )

    if nix_old_version and nix_old_version != version:
        commit_message = f"{nix_pname}: {nix_old_version} -> {version}"
    else:
        commit_message = f"{nix_pname}: {version}"

    if dry_run:
        log(f"cat >{filename} <<EOF")
        log(content)
        log("EOF")
    else:
        with open(filename, "w") as f:
            f.write(content)

    if commit:
        git("add", filename, dry_run=dry_run)
        git("commit", "--message", commit_message, dry_run=dry_run)


def helm_pull(chart: str, repo: str) -> str:
    tmpdir = tempfile.mkdtemp()
    out_dir = os.path.join(tmpdir, "out")
    os.makedirs(out_dir, exist_ok=True)
    os.environ["HELM_CACHE_HOME"] = os.path.join(tmpdir, ".cache")
    cmd = [
        HELM_PATH,
        "pull",
        chart,
        "--repo",
        repo,
        "--destination",
        out_dir,
        "--untar",
    ]
    log_cmd(cmd)
    result = subprocess.run(cmd, capture_output=True, text=True)
    result.check_returncode()
    return first_subdir(out_dir)


def helm_pull_oci(url: str) -> str:
    tmpdir = tempfile.mkdtemp()
    out_dir = os.path.join(tmpdir, "out")
    os.makedirs(out_dir, exist_ok=True)
    cmd = [
        HELM_PATH,
        "pull",
        url,
        "--destination",
        out_dir,
        "--untar",
    ]
    log_cmd(cmd)
    result = subprocess.run(cmd, capture_output=True, text=True)
    result.check_returncode()
    return first_subdir(out_dir)


def first_subdir(path: str) -> str:
    subdirs = [d for d in os.listdir(path) if os.path.isdir(os.path.join(path, d))]
    if not subdirs:
        raise RuntimeError(f"No subdirectory found in {path}")
    return os.path.join(path, subdirs[0])


def nix_hash(path: str) -> str:
    cmd = [NIX_HASH_PATH, "--type", "sha256", "--sri", path]
    log_cmd(cmd)
    result = subprocess.run(cmd, capture_output=True, text=True)
    result.check_returncode()
    return result.stdout.strip()


def nix_current_system() -> str:
    cmd = [NIX_PATH, "eval", "--raw", "--impure", "--expr", "builtins.currentSystem"]
    log_cmd(cmd)
    result = subprocess.run(cmd, capture_output=True, text=True)
    result.check_returncode()
    return result.stdout.strip()


def nix_attr_filename(attr_path: str) -> str:
    system = nix_current_system()
    cmd = [
        NIX_PATH,
        "eval",
        "--raw",
        "--impure",
        f".#packages.{system}.{attr_path}.meta.position",
    ]
    log_cmd(cmd)
    result = subprocess.run(cmd, capture_output=True, text=True)
    result.check_returncode()
    store_path = result.stdout.strip().rsplit(":", 1)[0]
    return "pkgs/" + store_path.split("/pkgs/", 1)[1]


def git(*args, dry_run: bool = False) -> None:
    cmd = [GIT_PATH] + list(args)
    log_cmd(cmd)
    if not dry_run:
        subprocess.run(cmd)


def log(message: str) -> None:
    print(message, file=sys.stderr)


def log_cmd(cmd: list[str]) -> None:
    log(f"+ {' '.join(cmd)}")


if __name__ == "__main__":
    main()
