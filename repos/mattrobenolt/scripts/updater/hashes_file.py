"""JSON file helpers for package update scripts."""

import json
from pathlib import Path
from typing import Any, cast


def load_json(path: Path, default: dict[str, Any] | None = None) -> dict[str, Any]:
    if not path.exists():
        return {} if default is None else default
    return cast(dict[str, Any], json.loads(path.read_text()))


def save_json(path: Path, data: dict[str, Any]) -> None:
    path.write_text(json.dumps(data, indent=2, sort_keys=True) + "\n")


load_hashes = load_json
save_hashes = save_json


def save_if_changed(path: Path, data: dict[str, Any]) -> bool:
    """Write data only when it differs from the file. Return True if written."""
    if load_json(path) == data:
        return False
    save_json(path, data)
    return True
