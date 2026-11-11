#!/usr/bin/env python3
"""Register the packaged desktop entry before launching CurseForge."""

import argparse
import configparser
import fcntl
import os
import subprocess
import sys
import tempfile
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("desktop_file", type=Path)
    parser.add_argument("database_builder", type=Path)
    args = parser.parse_args()
    if not os.environ.get("HOME"):
        raise RuntimeError("HOME must be set to launch CurseForge")
    home = Path(os.environ["HOME"])
    if not home.is_absolute():
        raise RuntimeError("HOME must be an absolute path")
    xdg_data_home = os.environ.get("XDG_DATA_HOME", "")
    data = Path(xdg_data_home) if xdg_data_home else home / ".local/share"
    if not data.is_absolute():
        raise RuntimeError("XDG_DATA_HOME must be an absolute path")
    source = args.desktop_file.resolve(strict=True)
    if not source.is_file():
        raise RuntimeError(f"Packaged desktop entry is not a file: {source}")
    data_dirs = os.environ.get("XDG_DATA_DIRS", "")
    installed_dirs = data_dirs.split(":") if data_dirs else ["/usr/local/share", "/usr/share"]
    if any(not Path(directory).is_absolute() for directory in installed_dirs):
        raise RuntimeError("XDG_DATA_DIRS must contain absolute directories")

    applications = data / "applications"
    state = data / "curseforge-nix"
    applications.mkdir(parents=True, exist_ok=True)
    state.mkdir(parents=True, exist_ok=True)
    desktop = applications / "curseforge.desktop"
    managed = state / "curseforge.desktop"

    # Follow installed profile paths across upgrades; standalone nix run uses its own output.
    selected = source
    for directory in installed_dirs:
        candidate_directory = Path(directory) / "applications"
        if candidate_directory.resolve(strict=False) == applications.resolve(strict=False):
            continue
        candidate = candidate_directory / "curseforge.desktop"
        if not candidate.is_file():
            continue
        entry = configparser.ConfigParser(interpolation=None)
        entry.optionxform = str
        entry.read_string(candidate.read_text())
        if entry.has_section("Desktop Entry") and entry["Desktop Entry"].get("X-Nix-CurseForge") == "true":
            selected = candidate
            break

    with (state / ".lock").open("a") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        legacy = home / ".nix-profile/share/applications/curseforge.desktop"
        if os.path.lexists(desktop) and (
            not desktop.is_symlink() or desktop.readlink() not in (managed, legacy)
        ):
            raise RuntimeError(f"Desktop entry conflict at {desktop}; move your custom entry before launching CurseForge")
        if os.path.lexists(managed) and not managed.is_symlink():
            raise RuntimeError(f"Registration state conflict at {managed}; move that file before launching CurseForge")

        def replace_link(destination, target):
            with tempfile.TemporaryDirectory(prefix=".registration-", dir=state) as temporary:
                staged = Path(temporary) / "desktop"
                staged.symlink_to(target)
                staged.replace(destination)

        # The stable intermediate link identifies our entry and retargets it atomically on upgrades.
        replace_link(managed, selected)
        if not os.path.lexists(desktop):
            desktop.symlink_to(managed)
        elif desktop.readlink() == legacy:
            # Adopt the profile link used by the earlier manual workaround without retaining that dependency.
            replace_link(desktop, managed)
        # Electron repeats GIO default registration before login, which can remove Added Associations.
        # A user MIME database keeps the handler discoverable after those calls.
        subprocess.run([str(args.database_builder), str(applications)], check=True)
    # Release the lock before FHS starts: browser callbacks launch another instance of the same wrapper.


if __name__ == "__main__":
    try:
        main()
    except (OSError, RuntimeError, configparser.Error, subprocess.CalledProcessError) as error:
        print(f"CurseForge could not register its desktop entry: {error}", file=sys.stderr)
        sys.exit(1)
