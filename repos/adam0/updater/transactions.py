from __future__ import annotations

import shutil
import tempfile
from pathlib import Path

from .process import ROOT, run


class FileTransaction:
    def __init__(self, owned_paths: list[Path]) -> None:
        self.owned_paths = sorted({path.resolve() for path in owned_paths if path.exists()})
        self._snapshot_files = _files_under(self.owned_paths)
        self._tmpdir: Path | None = None
        self._backups: dict[Path, Path] = {}
        self.before_diff = git_changed_files()

    def __enter__(self) -> FileTransaction:
        self._tmpdir = Path(tempfile.mkdtemp(prefix="update-package-"))
        for path in self._snapshot_files:
            backup = self._tmpdir / str(path.relative_to(ROOT)).replace("/", "__")
            backup.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(path, backup)
            self._backups[path] = backup
        return self

    def __exit__(self, exc_type: object, exc: object, tb: object) -> None:
        if self._tmpdir:
            shutil.rmtree(self._tmpdir, ignore_errors=True)

    def new_changed_files(self) -> set[Path]:
        return git_changed_files() - self.before_diff

    def restore(self) -> None:
        before = set(self._backups)
        for path in _files_under(self.owned_paths):
            if path not in before:
                path.unlink()
        for path, backup in self._backups.items():
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
