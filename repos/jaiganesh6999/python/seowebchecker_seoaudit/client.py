"""Cloud API Client for SEOWebChecker (https://seowebchecker.com/)."""

import json
import urllib.request
import urllib.error
from typing import Dict, Any, Optional, List

try:
    import requests
except ImportError:
    requests = None


class SeoWebCheckerError(Exception):
    """Base exception for SEOWebChecker API errors."""
    def __init__(self, message: str, status_code: Optional[int] = None, details: Optional[Dict[str, Any]] = None):
        super().__init__(message)
        self.status_code = status_code
        self.details = details or {}


class SeoWebCheckerClient:
    """Official Python Client for SEOWebChecker API (https://seowebchecker.com/)."""

    def __init__(
        self,
        api_key: Optional[str] = None,
        base_url: str = "https://seowebchecker.com/api/v1",
        timeout: int = 30,
    ):
        self.api_key = api_key
        self.base_url = base_url.rstrip("/")
        self.timeout = timeout

    def _headers(self) -> Dict[str, str]:
        headers = {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "User-Agent": "SEOWebChecker-Python-SDK/1.0.0 (+https://seowebchecker.com/)",
        }
        if self.api_key:
            headers["Authorization"] = f"Bearer {self.api_key}"
            headers["X-API-Key"] = self.api_key
        return headers

    def _request(self, method: str, endpoint: str, data: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        url = f"{self.base_url}/{endpoint.lstrip('/')}"
        headers = self._headers()

        if requests is not None:
            try:
                resp = requests.request(
                    method=method.upper(),
                    url=url,
                    json=data,
                    headers=headers,
                    timeout=self.timeout,
                )
                try:
                    payload = resp.json()
                except Exception:
                    payload = {"raw": resp.text}

                if not (200 <= resp.status_code < 300):
                    msg = payload.get("message") or payload.get("error") or f"HTTP {resp.status_code} error from API"
                    raise SeoWebCheckerError(msg, status_code=resp.status_code, details=payload)

                return payload
            except requests.RequestException as e:
                raise SeoWebCheckerError(f"Network error while connecting to SEOWebChecker: {e}")
        else:
            # Standard library urllib fallback
            body = json.dumps(data).encode("utf-8") if data is not None else None
            req = urllib.request.Request(url, data=body, headers=headers, method=method.upper())

            try:
                with urllib.request.urlopen(req, timeout=self.timeout) as response:
                    res_body = response.read().decode("utf-8")
                    try:
                        return json.loads(res_body)
                    except Exception:
                        return {"raw": res_body}
            except urllib.error.HTTPError as e:
                raw_body = e.read().decode("utf-8") if hasattr(e, "read") else ""
                try:
                    err_json = json.loads(raw_body)
                except Exception:
                    err_json = {"error": raw_body}
                msg = err_json.get("message") or err_json.get("error") or f"HTTP {e.code} error from API"
                raise SeoWebCheckerError(msg, status_code=e.code, details=err_json)
            except Exception as e:
                raise SeoWebCheckerError(f"Connection failure: {e}")

    def audit(self, url: str, options: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        """Trigger an SEO audit via SEOWebChecker cloud service.

        :param url: Website URL to audit (e.g., https://example.com)
        :param options: Optional audit parameters (device: mobile|desktop, check_cwv: bool)
        :return: Comprehensive audit report payload
        """
        payload = {"url": url}
        if options:
            payload.update(options)
        return self._request("POST", "audit", payload)

    def get_audit(self, audit_id: str) -> Dict[str, Any]:
        """Retrieve existing audit results by ID."""
        return self._request("GET", f"audit/{audit_id}")

    def get_history(self, limit: int = 10) -> List[Dict[str, Any]]:
        """Fetch recent audits performed under the account."""
        resp = self._request("GET", f"audits?limit={limit}")
        return resp.get("audits", [])

    def check_credits(self) -> Dict[str, Any]:
        """Check remaining API credits and subscription status."""
        return self._request("GET", "account/credits")
