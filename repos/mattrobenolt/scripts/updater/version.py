"""Version helpers for package update scripts."""

from typing import Any, cast

from .http import fetch_json


def parse_version(version: str) -> tuple[list[int], str]:
    version = version.lstrip("v")
    numeric, _, suffix = version.replace("+", "-").partition("-")
    try:
        return [int(part) for part in numeric.split(".")], suffix
    except ValueError:
        return [], version


def compare_versions(left: str, right: str) -> int:
    if left == right:
        return 0
    left_nums, left_suffix = parse_version(left)
    right_nums, right_suffix = parse_version(right)
    if not left_nums or not right_nums:
        return -1 if left < right else 1
    for index in range(max(len(left_nums), len(right_nums))):
        lval = left_nums[index] if index < len(left_nums) else 0
        rval = right_nums[index] if index < len(right_nums) else 0
        if lval != rval:
            return -1 if lval < rval else 1
    if left_suffix == right_suffix:
        return 0
    if not left_suffix:
        return 1
    if not right_suffix:
        return -1
    return -1 if left_suffix < right_suffix else 1


def should_update(current: str, latest: str) -> bool:
    return compare_versions(current, latest) < 0


def fetch_github_releases(
    owner: str, repo: str, *, per_page: int = 30
) -> list[dict[str, Any]]:
    data = fetch_json(
        f"https://api.github.com/repos/{owner}/{repo}/releases?per_page={per_page}"
    )
    if not isinstance(data, list):
        raise TypeError(f"Expected list from GitHub releases API, got {type(data)}")
    return cast(list[dict[str, Any]], data)


def fetch_github_latest_release(owner: str, repo: str) -> str:
    releases = fetch_github_releases(owner, repo, per_page=1)
    if not releases:
        raise ValueError(f"No releases found for {owner}/{repo}")
    return cast(str, releases[0]["tag_name"]).lstrip("v")
