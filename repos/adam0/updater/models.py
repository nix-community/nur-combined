from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path
from typing import Literal

VersionMode = Literal["stable", "branch"]
SourceKind = Literal["flake", "file"]
ResultStatus = Literal["updated", "skipped", "invalid", "failed"]


@dataclass(frozen=True)
class PackageRef:
    source_kind: SourceKind
    attrset: str
    attr: str
    attr_path: str
    file_path: Path


@dataclass(frozen=True)
class PackageState:
    version: str
    version_mode: VersionMode
    src_url: str | None = None
    src_rev: str | None = None
    src_hash: str | None = None
    dependency_hash: str | None = None


@dataclass(frozen=True)
class UpdateResult:
    name: str
    status: ResultStatus
    reason: str
    changed_files: list[Path] = field(default_factory=list)


@dataclass(frozen=True)
class ValidationResult:
    accepted: bool
    reason: str
    dependency_hash_refresh_allowed: bool = False
