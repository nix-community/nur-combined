from __future__ import annotations

import logging
from collections.abc import Iterable

from .models import PackageRef
from .nix import attr_file_path, list_derivations, list_file_attrsets

logger = logging.getLogger(__name__)


def discover_packages(system: str) -> list[PackageRef]:
    refs: list[PackageRef] = []
    for attrset in list_file_attrsets():
        refs.extend(_refs_for_attrset(attrset))
    logger.info("discovered %d package(s) for %s", len(refs), system)
    return refs


def filter_packages(refs: Iterable[PackageRef], selected: list[str]) -> list[PackageRef]:
    if not selected:
        return list(refs)
    wanted = set(selected)
    return [ref for ref in refs if ref.attr_path in wanted or ref.attr in wanted]


def _refs_for_attrset(attrset: str) -> list[PackageRef]:
    refs: list[PackageRef] = []
    attrs = list_derivations(attrset)
    logger.info("found %d derivation(s) in %s", len(attrs), attrset or "default.nix")
    for attr in attrs:
        file_path = attr_file_path(attrset, attr)
        if not file_path:
            logger.info("skipping %s.%s: no source file", attrset, attr)
            continue
        refs.append(
            PackageRef(
                attrset=attrset,
                attr=attr,
                attr_path=f"{attrset}.{attr}" if attrset else attr,
                file_path=file_path,
            )
        )
    return refs
