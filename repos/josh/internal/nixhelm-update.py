import os
import re
import subprocess
import sys
import tempfile

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
@click.option("--position-file")
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
    position_file: str | None,
    filename: str | None,
    commit: bool,
    dry_run: bool,
):
    if not filename and position_file:
        filename = pkgs_relative_path(position_file)

    if not filename and nix_attr_path:
        filename = nix_attr_filename(attr_path=nix_attr_path)

    if not filename:
        raise click.UsageError("filename is required")

    with open(filename, "r") as f:
        original_content = content = f.read()

    if not nix_pname:
        nix_pname = os.path.basename(filename).removesuffix(".nix")

    with tempfile.TemporaryDirectory() as tmpdir:
        if url.startswith("oci://"):
            chart_path = helm_pull_oci(url=url, tmpdir=tmpdir)
        elif chart and url:
            chart_path = helm_pull(chart=chart, repo=url, tmpdir=tmpdir)
        else:
            raise click.UsageError("chart name is required")

        with open(f"{chart_path}/Chart.yaml", "r") as f:
            chart_data = yaml.safe_load(f)
        if chart and chart_data["name"] != chart:
            raise RuntimeError(
                f"chart name mismatch in {filename}: "
                f"expected {chart}, got {chart_data['name']}"
            )
        version = chart_data["version"].removeprefix("v")

        sha256 = nix_hash(chart_path)

    content, n = re.subn(
        r'(^\s+version = ")([^"]*)(")',
        lambda m: m.group(1) + version + m.group(3),
        content,
        count=1,
        flags=re.MULTILINE,
    )
    if n != 1:
        raise RuntimeError(f"no version line found in {filename}")

    content, n = re.subn(
        r'(^\s+hash = ")([^"]*)(")',
        lambda m: m.group(1) + sha256 + m.group(3),
        content,
        count=1,
        flags=re.MULTILINE,
    )
    if n != 1:
        raise RuntimeError(f"no hash line found in {filename}")

    if nix_old_version and nix_old_version != version:
        commit_message = f"{nix_pname}: {nix_old_version} -> {version}"
    else:
        commit_message = f"{nix_pname}: {version}"

    if content == original_content:
        log(f"{filename} already up to date")
        return

    if dry_run:
        log(f"cat >{filename} <<'EOF'")
        log(content)
        log("EOF")
    else:
        with open(filename, "w") as f:
            f.write(content)

    if commit:
        git("add", filename, dry_run=dry_run)
        git("commit", "--message", commit_message, dry_run=dry_run)


def helm_env(tmpdir: str) -> dict[str, str]:
    return {
        **os.environ,
        "HELM_CACHE_HOME": os.path.join(tmpdir, ".cache"),
        "HELM_CONFIG_HOME": os.path.join(tmpdir, ".config"),
        "HELM_DATA_HOME": os.path.join(tmpdir, ".data"),
    }


def helm_pull(chart: str, repo: str, tmpdir: str) -> str:
    out_dir = os.path.join(tmpdir, "out")
    os.makedirs(out_dir, exist_ok=True)
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
    result = subprocess.run(cmd, capture_output=True, text=True, env=helm_env(tmpdir))
    check_result(result)
    return first_subdir(out_dir)


def helm_pull_oci(url: str, tmpdir: str) -> str:
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
    result = subprocess.run(cmd, capture_output=True, text=True, env=helm_env(tmpdir))
    check_result(result)
    return first_subdir(out_dir)


def first_subdir(path: str) -> str:
    subdirs = [d for d in os.listdir(path) if os.path.isdir(os.path.join(path, d))]
    if len(subdirs) != 1:
        raise RuntimeError(
            f"Expected exactly one subdirectory in {path}, found {subdirs}"
        )
    return os.path.join(path, subdirs[0])


def nix_hash(path: str) -> str:
    cmd = [NIX_HASH_PATH, "--type", "sha256", "--sri", path]
    log_cmd(cmd)
    result = subprocess.run(cmd, capture_output=True, text=True)
    check_result(result)
    return result.stdout.strip()


def nix_current_system() -> str:
    cmd = [NIX_PATH, "eval", "--raw", "--impure", "--expr", "builtins.currentSystem"]
    log_cmd(cmd)
    result = subprocess.run(cmd, capture_output=True, text=True)
    check_result(result)
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
    check_result(result)
    store_path = result.stdout.strip().rsplit(":", 1)[0]
    return pkgs_relative_path(store_path)


def pkgs_relative_path(path: str) -> str:
    _, sep, rest = path.rpartition("/pkgs/")
    if not sep:
        raise RuntimeError(f"position {path!r} is not under pkgs/")
    return "pkgs/" + rest


def check_result(result: subprocess.CompletedProcess) -> None:
    if result.returncode != 0 and result.stderr:
        log(result.stderr.rstrip())
    result.check_returncode()


def git(*args, dry_run: bool = False) -> None:
    cmd = [GIT_PATH] + list(args)
    log_cmd(cmd)
    if not dry_run:
        subprocess.run(cmd, check=True)


def log(message: str) -> None:
    print(message, file=sys.stderr)


def log_cmd(cmd: list[str]) -> None:
    log(f"+ {' '.join(cmd)}")


if __name__ == "__main__":
    main()
