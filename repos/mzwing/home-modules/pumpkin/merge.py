import argparse
import copy
import json
import os
import shutil
import sys
import tempfile
from pathlib import Path
from typing import Any

import tomli_w
import tomllib

STATE_VERSION = 1


class ConfigError(RuntimeError):
    pass


def load_toml(path: Path, description: str) -> dict[str, Any]:
    if not path.is_file():
        raise ConfigError(f"{description} is not a readable regular file: {path}")

    try:
        with path.open("rb") as file:
            return tomllib.load(file)
    except (OSError, tomllib.TOMLDecodeError) as error:
        raise ConfigError(f"could not read {description} {path}: {error}") from error


def load_runtime_config(path: Path) -> dict[str, Any]:
    if path.is_symlink():
        raise ConfigError(f"runtime config is not a regular file: {path}")
    if not path.exists():
        return {}
    if not path.is_file():
        raise ConfigError(f"runtime config is not a regular file: {path}")
    return load_toml(path, "runtime config")


def leaf_paths(value: Any, prefix: tuple[str, ...] = ()) -> list[tuple[str, ...]]:
    if isinstance(value, dict):
        if not value and prefix:
            return [prefix]
        result: list[tuple[str, ...]] = []
        for key, child in value.items():
            result.extend(leaf_paths(child, prefix + (key,)))
        return result
    return [prefix]


def remove_path(root: dict[str, Any], path: tuple[str, ...]) -> None:
    if not path:
        return

    parents: list[tuple[dict[str, Any], str]] = []
    current: Any = root
    for key in path[:-1]:
        if not isinstance(current, dict) or key not in current:
            return
        parents.append((current, key))
        current = current[key]

    if not isinstance(current, dict):
        return
    current.pop(path[-1], None)

    for parent, key in reversed(parents):
        child = parent.get(key)
        if isinstance(child, dict) and not child:
            parent.pop(key)
        else:
            break


def merge(base: dict[str, Any], overlay: dict[str, Any]) -> dict[str, Any]:
    for key, value in overlay.items():
        if isinstance(value, dict) and value and isinstance(base.get(key), dict):
            merge(base[key], value)
        else:
            base[key] = copy.deepcopy(value)
    return base


def load_state(path: Path) -> list[tuple[str, ...]]:
    if path.is_symlink():
        raise ConfigError(f"managed-path state is not a regular file: {path}")
    if not path.exists():
        return []
    if not path.is_file():
        raise ConfigError(f"managed-path state is not a regular file: {path}")

    try:
        state = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise ConfigError(
            f"could not read managed-path state {path}: {error}"
        ) from error

    if not isinstance(state, dict) or state.get("version") != STATE_VERSION:
        raise ConfigError(f"unsupported managed-path state: {path}")
    paths = state.get("managed_paths")
    if not isinstance(paths, list):
        raise ConfigError(f"invalid managed-path state: {path}")

    result: list[tuple[str, ...]] = []
    for path_value in paths:
        if not isinstance(path_value, list) or not all(
            isinstance(part, str) for part in path_value
        ):
            raise ConfigError(f"invalid managed path in state: {path}")
        result.append(tuple(path_value))
    return result


def temporary_file(directory: Path, prefix: str, content: bytes) -> Path:
    file_descriptor, name = tempfile.mkstemp(dir=directory, prefix=prefix)
    path = Path(name)
    try:
        with os.fdopen(file_descriptor, "wb") as file:
            file.write(content)
            file.flush()
            os.fsync(file.fileno())
        path.chmod(0o600)
    except BaseException:
        path.unlink(missing_ok=True)
        raise
    return path


def replace_if_changed(temporary: Path, destination: Path) -> None:
    try:
        if destination.is_file() and not destination.is_symlink():
            if temporary.read_bytes() == destination.read_bytes():
                destination.chmod(0o600)
                temporary.unlink()
                return
        os.replace(temporary, destination)
    finally:
        temporary.unlink(missing_ok=True)


def write_outputs(
    config_path: Path,
    state_path: Path,
    config: dict[str, Any],
    managed_paths: list[tuple[str, ...]],
) -> None:
    try:
        config_content = tomli_w.dumps(config).encode()
    except (TypeError, ValueError) as error:
        raise ConfigError(
            f"could not serialize merged configuration: {error}"
        ) from error

    state_content = (
        json.dumps(
            {
                "version": STATE_VERSION,
                "managed_paths": [list(path) for path in managed_paths],
            },
            indent=2,
            sort_keys=True,
        )
        + "\n"
    ).encode()

    config_temp = temporary_file(config_path.parent, ".pumpkin.toml.", config_content)
    try:
        state_temp = temporary_file(
            state_path.parent, ".pumpkin-managed.", state_content
        )
    except BaseException:
        config_temp.unlink(missing_ok=True)
        raise

    try:
        # Commit bookkeeping first. If replacing the runtime config then fails,
        # the old config remains valid and the next invocation can safely retry
        # with the new path set.
        replace_if_changed(state_temp, state_path)
        replace_if_changed(config_temp, config_path)
    finally:
        config_temp.unlink(missing_ok=True)
        state_temp.unlink(missing_ok=True)


def back_up_initial_config(
    config_path: Path, state_path: Path, backup_path: Path
) -> None:
    if state_path.exists() or not config_path.exists() or backup_path.exists():
        return
    if config_path.is_symlink() or not config_path.is_file():
        raise ConfigError(f"runtime config is not a regular file: {config_path}")
    try:
        shutil.copyfile(config_path, backup_path)
        backup_path.chmod(0o600)
    except OSError as error:
        backup_path.unlink(missing_ok=True)
        raise ConfigError(
            f"could not back up {config_path} to {backup_path}: {error}"
        ) from error


def parse_arguments() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Merge schema-agnostic Home Manager settings into Pumpkin TOML"
    )
    parser.add_argument("config", type=Path, help="Writable runtime pumpkin.toml")
    parser.add_argument("settings", type=Path, help="Declarative TOML settings")
    parser.add_argument("state", type=Path, help="Managed-path state file")
    parser.add_argument("backup", type=Path, help="One-time stateful backup")
    parser.add_argument(
        "secret", type=Path, nargs="?", help="Optional secret TOML overlay"
    )
    return parser.parse_args()


def main() -> int:
    arguments = parse_arguments()
    config_path: Path = arguments.config
    state_path: Path = arguments.state
    backup_path: Path = arguments.backup

    try:
        config_path.parent.mkdir(parents=True, exist_ok=True)
        if (
            state_path.parent != config_path.parent
            or backup_path.parent != config_path.parent
        ):
            raise ConfigError("config, state, and backup files must share a directory")

        settings = load_toml(arguments.settings, "declarative settings")
        secret = (
            load_toml(arguments.secret, "secret settings")
            if arguments.secret is not None
            else {}
        )
        runtime = load_runtime_config(config_path)
        old_paths = load_state(state_path)

        for old_path in old_paths:
            remove_path(runtime, old_path)

        merge(runtime, settings)
        merge(runtime, secret)

        managed_paths = sorted(set(leaf_paths(settings) + leaf_paths(secret)))
        back_up_initial_config(config_path, state_path, backup_path)
        write_outputs(config_path, state_path, runtime, managed_paths)
    except (ConfigError, OSError) as error:
        print(f"pumpkin: {error}", file=sys.stderr)
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
