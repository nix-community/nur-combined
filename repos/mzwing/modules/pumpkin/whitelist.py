import argparse
import json
import os
import shutil
import sys
import tempfile
from pathlib import Path
from typing import Any

STATE_VERSION = 1


class WhitelistError(RuntimeError):
    pass


def read_source(path: Path) -> bytes:
    if not path.is_file():
        raise WhitelistError(f"whitelist source is not a readable regular file: {path}")
    try:
        content = path.read_bytes()
        parsed: Any = json.loads(content)
    except (OSError, json.JSONDecodeError) as error:
        raise WhitelistError(
            f"could not read whitelist source {path}: {error}"
        ) from error

    if not isinstance(parsed, list):
        raise WhitelistError("whitelist source must contain a JSON array")
    for entry in parsed:
        if not isinstance(entry, dict) or set(entry) != {"name", "uuid"}:
            raise WhitelistError("each whitelist entry must contain only name and uuid")
        if not isinstance(entry["name"], str) or not isinstance(entry["uuid"], str):
            raise WhitelistError("whitelist names and UUIDs must be strings")
    return (json.dumps(parsed, indent=2, sort_keys=True) + "\n").encode()


def write_atomic(path: Path, content: bytes) -> None:
    file_descriptor, temporary_name = tempfile.mkstemp(
        dir=path.parent, prefix=f".{path.name}."
    )
    temporary = Path(temporary_name)
    try:
        with os.fdopen(file_descriptor, "wb") as file:
            file.write(content)
            file.flush()
            os.fsync(file.fileno())
        temporary.chmod(0o600)

        if path.is_file() and not path.is_symlink() and path.read_bytes() == content:
            path.chmod(0o600)
            temporary.unlink()
        else:
            os.replace(temporary, path)
    finally:
        temporary.unlink(missing_ok=True)


def load_state(path: Path) -> bool:
    if path.is_symlink() or not path.is_file():
        raise WhitelistError(f"whitelist state is not a regular file: {path}")
    try:
        state = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise WhitelistError(
            f"could not read whitelist state {path}: {error}"
        ) from error
    if (
        not isinstance(state, dict)
        or state.get("version") != STATE_VERSION
        or not isinstance(state.get("had_original"), bool)
    ):
        raise WhitelistError(f"invalid whitelist state: {path}")
    return state["had_original"]


def reject_unsafe_target(path: Path, description: str) -> None:
    if path.is_symlink() or (path.exists() and not path.is_file()):
        raise WhitelistError(f"{description} is not a regular file: {path}")


def enable_management(target: Path, source: Path, state: Path, backup: Path) -> None:
    content = read_source(source)
    reject_unsafe_target(target, "runtime whitelist")
    reject_unsafe_target(state, "whitelist state")
    reject_unsafe_target(backup, "whitelist backup")

    if state.exists():
        had_original = load_state(state)
        if had_original and not backup.is_file():
            raise WhitelistError(f"whitelist backup is missing: {backup}")
    else:
        if backup.exists():
            raise WhitelistError(
                f"refusing to overwrite untracked whitelist backup: {backup}"
            )
        had_original = target.exists()
        if had_original:
            try:
                shutil.copyfile(target, backup)
                backup.chmod(0o600)
            except OSError as error:
                backup.unlink(missing_ok=True)
                raise WhitelistError(
                    f"could not back up {target} to {backup}: {error}"
                ) from error

    state_content = (
        json.dumps(
            {"version": STATE_VERSION, "had_original": had_original},
            indent=2,
            sort_keys=True,
        )
        + "\n"
    ).encode()

    write_atomic(state, state_content)
    write_atomic(target, content)


def disable_management(target: Path, state: Path, backup: Path) -> None:
    if not state.exists() and not state.is_symlink():
        return

    reject_unsafe_target(target, "runtime whitelist")
    reject_unsafe_target(state, "whitelist state")
    reject_unsafe_target(backup, "whitelist backup")
    had_original = load_state(state)

    if had_original:
        if not backup.is_file():
            raise WhitelistError(f"whitelist backup is missing: {backup}")
        write_atomic(target, backup.read_bytes())
        backup.unlink()
    else:
        target.unlink(missing_ok=True)
        backup.unlink(missing_ok=True)
    state.unlink()


def parse_arguments() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Manage Pumpkin's declarative whitelist"
    )
    parser.add_argument("mode", choices=("managed", "unmanaged"))
    parser.add_argument("target", type=Path)
    parser.add_argument("state", type=Path)
    parser.add_argument("backup", type=Path)
    parser.add_argument("source", type=Path, nargs="?")
    return parser.parse_args()


def main() -> int:
    arguments = parse_arguments()
    target: Path = arguments.target
    state: Path = arguments.state
    backup: Path = arguments.backup

    try:
        target.parent.mkdir(parents=True, exist_ok=True)
        if state.parent != target.parent or backup.parent != target.parent:
            raise WhitelistError(
                "target, state, and backup files must share a directory"
            )

        if arguments.mode == "managed":
            if arguments.source is None:
                raise WhitelistError("managed mode requires a whitelist source")
            enable_management(target, arguments.source, state, backup)
        else:
            if arguments.source is not None:
                raise WhitelistError(
                    "unmanaged mode does not accept a whitelist source"
                )
            disable_management(target, state, backup)
    except (OSError, WhitelistError) as error:
        print(f"pumpkin: {error}", file=sys.stderr)
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
