"""Discover GitHub release versions without downloading asset metadata."""

import os
import re

from .http import read_json


def query_repository(owner, repo, fields, *, variables=None, declarations=""):
    token = os.environ.get("GITHUB_TOKEN") or os.environ.get("GH_TOKEN")
    if not token:
        raise ValueError("GitHub updates require GITHUB_TOKEN or GH_TOKEN")
    query = f"""query($owner: String!, $repo: String! {declarations}) {{
      repository(owner: $owner, name: $repo) {{ {fields} }}
    }}"""
    result = read_json(
        "https://api.github.com/graphql",
        data={
            "query": query,
            "variables": {"owner": owner, "repo": repo} | (variables or {}),
        },
        headers={"Authorization": f"Bearer {token}"},
    )
    if result.get("errors"):
        messages = "; ".join(error["message"] for error in result["errors"])
        raise ValueError(f"GitHub query failed: {messages}")
    repository = result["data"]["repository"]
    if repository is None:
        raise ValueError(f"GitHub repository not found: {owner}/{repo}")
    return repository


def release_version(owner, repo, pattern, *, prerelease=False):
    expression = re.compile(pattern)
    candidates = {}
    cursor = None
    seen_cursors = set()
    while True:
        repository = query_repository(
            owner,
            repo,
            """releases(first: 100, after: $cursor, orderBy: {field: CREATED_AT, direction: DESC}) {
              nodes { tagName isPrerelease isDraft }
              pageInfo { hasNextPage endCursor }
            }""",
            declarations=", $cursor: String",
            variables={"cursor": cursor},
        )
        releases = repository["releases"]
        for release in releases["nodes"]:
            if release["isDraft"] or release["isPrerelease"] != prerelease:
                continue
            match = expression.fullmatch(release["tagName"])
            if match is None:
                continue
            version = match.group(1)
            # Current packages use numeric releases, optionally with a dated nightly suffix.
            if not re.fullmatch(r"\d+\.\d+\.\d+(?:-nightly\.\d{8}\.\d+)?", version):
                raise ValueError(f"Unsupported version: {version}")
            key = tuple(int(part) for part in re.findall(r"\d+", version))
            candidates[key] = version
        page = releases["pageInfo"]
        if not page["hasNextPage"]:
            break
        cursor = page["endCursor"]
        if not cursor or cursor in seen_cursors:
            raise ValueError("GitHub returned an invalid release cursor")
        seen_cursors.add(cursor)
    if not candidates:
        raise ValueError(f"No matching releases for {owner}/{repo}: {pattern}")
    return candidates[max(candidates)]
