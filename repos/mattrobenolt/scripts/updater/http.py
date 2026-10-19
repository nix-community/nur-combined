"""HTTP helpers for package update scripts."""

import json
import os
from typing import Any
from urllib.parse import urlsplit
from urllib.request import Request, urlopen

GITHUB_API_HOST = "api.github.com"


def fetch_text(url: str) -> str:
    headers = {"User-Agent": "mattrobenolt-nixpkgs-updater"}
    # Authenticate GitHub API calls when a token is available. The scheduled
    # updaters all fire in the same hour and exhaust the unauthenticated
    # 60-request hourly limit. Do not send the token to other hosts.
    token = os.environ.get("GITHUB_TOKEN")
    if token and urlsplit(url).hostname == GITHUB_API_HOST:
        headers["Authorization"] = f"Bearer {token}"
    request = Request(url, headers=headers)
    with urlopen(request) as response:
        return response.read().decode("utf-8")


def fetch_json(url: str) -> Any:
    return json.loads(fetch_text(url))
