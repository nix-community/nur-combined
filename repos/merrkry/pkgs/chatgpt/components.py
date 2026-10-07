"""Extract the bundled Linux components used by the package and updater."""

import argparse
import shutil
import subprocess
from pathlib import Path
from tempfile import TemporaryDirectory

COMPONENTS = ("cua_node", "tectonic")


def prune_prebuilds(root: Path) -> None:
    """Keep Linux x86_64 glibc prebuilds."""
    for prebuilds in root.rglob("prebuilds"):
        if not prebuilds.is_dir() or prebuilds.is_symlink():
            continue
        for path in prebuilds.iterdir():
            if path.name.endswith("linux-x64"):
                continue
            if path.is_dir() and not path.is_symlink():
                shutil.rmtree(path)
            else:
                path.unlink()

    for path in root.rglob("*.musl.node"):
        path.unlink()


def extract_components(
    archive: Path,
    destination: Path,
    components: list[str] | tuple[str, ...],
    dpkg_deb: str,
) -> None:
    """Copy components from a verified archive without adding store references."""
    with TemporaryDirectory() as directory:
        subprocess.run([dpkg_deb, "--extract", str(archive), directory], check=True)
        resources = Path(directory) / "usr/lib/chatgpt/resources"

        for component in components:
            output = destination / component
            shutil.copytree(resources / component, output, symlinks=True)
            prune_prebuilds(output)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest="command", required=True)

    extract = commands.add_parser("extract")
    extract.add_argument("archive", type=Path)
    extract.add_argument("destination", type=Path)
    extract.add_argument("--component", choices=COMPONENTS, action="append")
    extract.add_argument("--dpkg-deb", required=True)

    prune = commands.add_parser("prune")
    prune.add_argument("directory", type=Path)

    arguments = parser.parse_args()
    if arguments.command == "prune":
        prune_prebuilds(arguments.directory)
    else:
        extract_components(
            arguments.archive,
            arguments.destination,
            arguments.component or COMPONENTS,
            arguments.dpkg_deb,
        )


if __name__ == "__main__":
    main()
