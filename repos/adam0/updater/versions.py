from __future__ import annotations

import re

from .models import VersionMode
from .process import run

BRANCH_RE = re.compile(r"^(?:(?P<prefix>.+)-)?unstable-(?P<date>\d{4}-\d{2}-\d{2})$")
NUMERIC_RE = re.compile(r"^v?\d")


def version_mode(version: str) -> VersionMode:
    if re.search(r"(^|[-._])(?:unstable|git)($|[-._0-9])", version):
        return "branch"
    return "stable"


def branch_parts(version: str) -> tuple[str, str] | None:
    match = BRANCH_RE.match(version)
    if not match:
        return None
    return (match.group("prefix") or "0", match.group("date"))


def should_block_downgrade(before: str, after: str) -> bool:
    return bool(before and after and NUMERIC_RE.match(before) and NUMERIC_RE.match(after))


def version_is_older(candidate: str, baseline: str) -> bool:
    expr = (
        f'if builtins.compareVersions "{_escape(candidate)}" "{_escape(baseline)}" < 0 '
        'then "1" else "0"'
    )
    result = run(["nix", "eval", "--raw", "--expr", expr], check=False)
    return result.stdout.strip() == "1"


def _escape(value: str) -> str:
    return value.replace("\\", "\\\\").replace('"', '\\"')
