"""HTTP helpers for package update scripts."""

import json
from typing import Any
from urllib.request import Request, urlopen


def fetch_text(url: str) -> str:
    request = Request(url, headers={"User-Agent": "mattrobenolt-nixpkgs-updater"})
    with urlopen(request) as response:
        return response.read().decode("utf-8")


def fetch_json(url: str) -> Any:
    return json.loads(fetch_text(url))
