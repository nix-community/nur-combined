from __future__ import annotations

import shutil
import tempfile
from pathlib import Path
from typing import Self

from .process import ROOT, run


class FileTransaction:
    """Roll back package-owned files unless the caller explicitly accepts the update."""

    def __init__(self, owned_paths: list[Path]) -> None:
        self.owned_paths = sorted({path.resolve() for path in owned_paths})
        self._tmpdir: tempfile.TemporaryDirectory[str] | None = None
        self._backups: dict[Path, Path] = {}
        self._committed = False
        self.before_diff: set[Path] = set()

    def __enter__(self) -> Self:
        self.before_diff = git_changed_files()
        self._tmpdir = tempfile.TemporaryDirectory(prefix="update-package-")
        try:
            for index, path in enumerate(_files_under(self.owned_paths)):
                backup = Path(self._tmpdir.name) / str(index)
                shutil.copy2(path, backup)
                self._backups[path] = backup
        except BaseException:
            self._tmpdir.cleanup()
            raise
        return self

    def commit(self) -> None:
        self._committed = True

    def __exit__(self, exc_type: object, exc: object, tb: object) -> None:
        try:
            if exc_type is not None or not self._committed:
                self.restore()
        finally:
            if self._tmpdir:
                self._tmpdir.cleanup()

    def new_changed_files(self) -> set[Path]:
        changed = git_changed_files() - self.before_diff
        current = set(_files_under(self.owned_paths))
        changed.update(current.symmetric_difference(self._backups))
        changed.update(
            path
            for path in current.intersection(self._backups)
            if path.read_bytes() != self._backups[path].read_bytes()
        )
        return changed

    def restore(self) -> None:
        before = set(self._backups)
        for path in _files_under(self.owned_paths):
            if path not in before:
                path.unlink()
        for path, backup in self._backups.items():
            path.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(backup, path)


def git_changed_files() -> set[Path]:
    result = run(["git", "diff", "--name-only"], check=False)
    return {ROOT / line for line in result.stdout.splitlines() if line}


def paths_owned_by(changed: set[Path], owned_roots: list[Path]) -> tuple[set[Path], set[Path]]:
    owned: set[Path] = set()
    unrelated: set[Path] = set()
    roots = [path.resolve() for path in owned_roots]
    for path in changed:
        resolved = path.resolve()
        if any(resolved == root or root in resolved.parents for root in roots):
            owned.add(path)
        else:
            unrelated.add(path)
    return owned, unrelated


def _files_under(paths: list[Path]) -> list[Path]:
    files: set[Path] = set()
    for path in paths:
        if path.is_file():
            files.add(path.resolve())
        elif path.is_dir():
            files.update(child.resolve() for child in path.rglob("*") if child.is_file())
    return sorted(files)
