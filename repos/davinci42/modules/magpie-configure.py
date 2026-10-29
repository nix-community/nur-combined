import argparse
import json
import os
import sys
import tempfile
from pathlib import Path
from typing import cast


class ConfigurationError(Exception):
    pass


def object_dict(value: object) -> dict[str, object]:
    if not isinstance(value, dict):
        raise ConfigurationError("Expected a JSON object")
    return cast(dict[str, object], value)


def read_object(path: str | Path) -> dict[str, object]:
    raw = Path(path).read_bytes().removeprefix(b"\xef\xbb\xbf").strip()
    if not raw:
        return {}
    return object_dict(cast(object, json.loads(raw.decode())))


def read_managed_keys(path: Path) -> set[str]:
    if not path.exists():
        return set()
    raw = path.read_bytes().strip()
    if not raw:
        return set()
    parsed = cast(object, json.loads(raw.decode()))
    if not isinstance(parsed, list) or not all(
        isinstance(item, str) for item in cast(list[object], parsed)
    ):
        raise ConfigurationError("Managed keys ledger must be a JSON string array")
    return set(cast(list[str], parsed))


def write_private_atomic(path: Path, data: bytes) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    descriptor, temporary_name = tempfile.mkstemp(
        prefix=f".{path.name}.", dir=str(path.parent)
    )
    temporary = Path(temporary_name)
    try:
        os.fchmod(descriptor, 0o600)
        with os.fdopen(descriptor, "wb") as handle:
            _ = handle.write(data)
            handle.flush()
            os.fsync(handle.fileno())
        _ = temporary.replace(path)
    except BaseException:
        temporary.unlink(missing_ok=True)
        raise


def load_declared(
    declared_path: str | Path, secret_file: str | Path | None
) -> dict[str, object]:
    declared = {
        key: value
        for key, value in read_object(declared_path).items()
        if value is not None
    }
    if secret_file:
        private = {
            key: value
            for key, value in read_object(secret_file).items()
            if value is not None
        }
        if declared.keys() & private.keys():
            raise ConfigurationError(
                "settings and settingsFile must not contain duplicate keys"
            )
        declared.update(private)
    return declared


def sync_settings(
    config_dir: str | Path,
    declared_path: str | Path,
    secret_file: str | Path | None = None,
) -> dict[str, object]:
    folder = Path(config_dir)
    settings_path = folder / "settings.json"
    ledger_path = folder / ".nix-managed-keys.json"
    declared = load_declared(declared_path, secret_file)
    previously_managed = read_managed_keys(ledger_path)

    if not declared and not previously_managed:
        return read_object(settings_path) if settings_path.exists() else {}

    current = read_object(settings_path) if settings_path.exists() else {}
    for stale_key in previously_managed - declared.keys():
        _ = current.pop(stale_key, None)
    current.update(declared)

    serialized = (json.dumps(current, indent=2) + "\n").encode()
    write_private_atomic(settings_path, serialized)
    if declared:
        ledger_bytes = (json.dumps(sorted(declared.keys()), indent=2) + "\n").encode()
        write_private_atomic(ledger_path, ledger_bytes)
    else:
        ledger_path.unlink(missing_ok=True)
    return current


def resolve_config_dir(explicit: str | None = None) -> Path:
    if explicit:
        return Path(explicit)
    xdg = os.environ.get("XDG_CONFIG_HOME", "").strip()
    if xdg.startswith("/"):
        return Path(xdg) / "magpie"
    home = os.environ.get("HOME", "").strip()
    if not home.startswith("/"):
        raise ConfigurationError("HOME or XDG_CONFIG_HOME must be an absolute path")
    return Path(home) / ".config" / "magpie"


class Arguments(argparse.Namespace):
    settings: str = ""
    settings_file: str | None = None
    config_dir: str | None = None


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Synchronize Nix-declared Magpie settings while preserving unmanaged runtime fields"
    )
    _ = parser.add_argument("settings")
    _ = parser.add_argument("--settings-file")
    _ = parser.add_argument("--config-dir")
    args = parser.parse_args(argv, namespace=Arguments())
    try:
        config_dir = resolve_config_dir(args.config_dir)
        _ = sync_settings(config_dir, args.settings, args.settings_file)
    except ConfigurationError as error:
        print(str(error), file=sys.stderr)
        return 1
    except (OSError, ValueError, KeyError, TypeError):
        print(
            "Failed to synchronize Magpie settings; check file permissions and JSON syntax",
            file=sys.stderr,
        )
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
