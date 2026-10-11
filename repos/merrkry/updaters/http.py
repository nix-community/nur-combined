"""HTTP requests with bounded retries for transport failures."""

import json
import sys
import time
from http.client import IncompleteRead
from typing import Any
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen


def read_url(
    url: str, *, data: bytes | None = None, headers: dict[str, str] | None = None
) -> bytes:
    request = Request(
        url, data=data, headers={"User-Agent": "nur-updater"} | (headers or {})
    )
    for attempt in range(3):
        try:
            with urlopen(request, timeout=60) as response:
                return response.read()
        except HTTPError as error:
            if error.code not in {408, 429, 500, 502, 503, 504}:
                raise
            failure = error
        except (URLError, IncompleteRead, TimeoutError, ConnectionError) as error:
            failure = error
        if attempt == 2:
            raise failure
        print(f"Retrying {url}: {failure}", file=sys.stderr, flush=True)
        time.sleep(2**attempt)
    raise AssertionError("Unreachable")


def read_json(
    url: str, *, data: object = None, headers: dict[str, str] | None = None
) -> Any:
    # JSON response shapes belong to the caller.
    body = None if data is None else json.dumps(data).encode()
    request_headers = {"Accept": "application/json"}
    if body is not None:
        request_headers["Content-Type"] = "application/json"
    response = read_url(url, data=body, headers=request_headers | (headers or {}))
    return json.loads(response)
