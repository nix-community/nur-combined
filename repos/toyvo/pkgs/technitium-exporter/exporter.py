#!/usr/bin/env python3
"""
Technitium DNS Server Prometheus Exporter

Polls the Technitium HTTP API for stats and query logs,
then exposes them as Prometheus metrics on :9187.

Metrics exposed:
  technitium_queries_total           — total queries since start
  technitium_queries_per_client       — queries per client IP (last N minutes)
  technitium_blocked_total            — total blocked queries
  technitium_blocked_per_client       — blocked queries per client IP
  technitium_cache_hit_ratio          — cache hit ratio (0–1 gauge)
  technitium_zones_loaded             — number of zones loaded
  technitium_threat_detected          — queries matching threat patterns
"""

import os
import re
import sys
import time
import threading
from http.server import HTTPServer, BaseHTTPRequestHandler

import requests
from prometheus_client import (
    CollectorRegistry,
    generate_latest,
    Gauge,
    Counter,
    CONTENT_TYPE_LATEST,
)

TECH_URL = os.environ.get("TECHNITIUM_URL", "http://127.0.0.1:5380")
API_TOKEN = os.environ.get("TECHNITIUM_TOKEN", "")
TOKEN_FILE = os.environ.get("TECHNITIUM_TOKEN_FILE", "")
if not API_TOKEN and TOKEN_FILE:
    try:
        with open(TOKEN_FILE, "r") as f:
            API_TOKEN = f.read().strip()
    except Exception:
        pass

ADMIN_PASS_FILE = os.environ.get("TECHNITIUM_ADMIN_PASS_FILE", "")
ADMIN_PASS = ""
if ADMIN_PASS_FILE:
    try:
        with open(ADMIN_PASS_FILE, "r") as f:
            ADMIN_PASS = f.read().strip()
    except Exception:
        pass

REFRESH = int(os.environ.get("TECHNITIUM_REFRESH", "30"))

# ---------------------------------------------------------------------------
# Auth helpers
# ---------------------------------------------------------------------------

def get_session_token():
    """Try API_TOKEN first, fall back to admin login."""
    if API_TOKEN:
        try:
            headers = {"Authorization": f"Bearer {API_TOKEN}"}
            r = requests.get(f"{TECH_URL}/api/stats", headers=headers, timeout=10)
            r.raise_for_status()
            data = r.json()
            if data.get("status") == "ok":
                print("Using configured API token for auth", file=sys.stderr)
                return API_TOKEN
        except Exception:
            pass
        print("Configured API token invalid, falling back to admin login", file=sys.stderr)

    if ADMIN_PASS:
        try:
            r = requests.post(
                f"{TECH_URL}/api/user/login",
                data={"user": "admin", "pass": ADMIN_PASS},
                timeout=10,
            )
            r.raise_for_status()
            data = r.json()
            if data.get("status") == "ok" and data.get("token"):
                print("Admin login successful, using session token", file=sys.stderr)
                return data["token"]
        except Exception:
            pass

    print("WARNING: no valid auth method available", file=sys.stderr)
    return None


_session_token = None

def active_token(force_refresh=False):
    global _session_token
    if _session_token is None or force_refresh:
        _session_token = get_session_token()
    return _session_token

# ---------------------------------------------------------------------------
# Metric definitions
# ---------------------------------------------------------------------------
registry = CollectorRegistry()

queries_total = Gauge(
    "technitium_queries_total",
    "Total DNS queries handled",
    registry=registry,
)
queries_per_client = Gauge(
    "technitium_queries_per_client",
    "Queries per client IP",
    ["client"],
    registry=registry,
)
blocked_total = Gauge(
    "technitium_blocked_total",
    "Total blocked queries",
    registry=registry,
)
blocked_per_client = Gauge(
    "technitium_blocked_per_client",
    "Blocked queries per client IP",
    ["client"],
    registry=registry,
)
cache_hits = Gauge(
    "technitium_cache_hits_total",
    "Total cache hits",
    registry=registry,
)
zones_loaded = Gauge(
    "technitium_zones_loaded",
    "Number of zones currently loaded",
    registry=registry,
)
threat_detected = Counter(
    "technitium_threat_detected_total",
    "Queries matching threat indicators",
    ["client", "domain", "indicator"],
    registry=registry,
)

# Known threat indicators (substrings to watch for)
THREAT_PATTERNS = [
    "pcaccelerate",
    "speedupmypc",
    "winzipper",
    "acceleratepro",
    "fodcha",
    "botnet",
    "checkip",
    "dga-check",
]

# Compile a quick regex for DGA detection
DGA_RE = re.compile(r"^[a-z0-9]{10,30}\.(xyz|top|cn|tk|ml|ga|cf|pw|club|info)$")


def api_get(endpoint, params=None):
    """GET from Technitium API; retry once on auth failure."""
    url = f"{TECH_URL}{endpoint}"
    token = active_token()
    headers = {}
    if token:
        headers["Authorization"] = f"Bearer {token}"
    try:
        r = requests.get(url, params=params, headers=headers, timeout=10)
        r.raise_for_status()
        data = r.json()
        # Detect auth failure and retry with fresh token
        if data.get("status") == "error" and "token" in str(data.get("errorMessage", "")).lower():
            token = active_token(force_refresh=True)
            if token:
                headers["Authorization"] = f"Bearer {token}"
                r = requests.get(url, params=params, headers=headers, timeout=10)
                r.raise_for_status()
                data = r.json()
        return data
    except Exception:
        return {}


def update_stats():
    """Poll /api/stats and update Prometheus gauges."""
    data = api_get("/api/stats")
    if not data:
        return

    stats = data.get("stats", data)  # API may wrap or not wrap
    queries_total.set(stats.get("totalQueries", 0))
    blocked_total.set(stats.get("totalBlocked", 0))
    cache_hits.set(stats.get("totalCacheHits", 0))
    zones_loaded.set(stats.get("zones", 0))

    # Per-client breakdown (if available in the response)
    clients = stats.get("clientQueries", {})
    for ip, count in clients.items():
        queries_per_client.labels(client=ip).set(count)

    blocked_clients = stats.get("clientBlocked", {})
    for ip, count in blocked_clients.items():
        blocked_per_client.labels(client=ip).set(count)


def check_threats():
    """Poll recent query logs and increment threat_detected for matches."""
    data = api_get("/api/logs", {"type": "Query", "page": "1", "limit": "500"})
    if not data:
        return

    logs = data.get("logs", [])
    for entry in logs:
        domain = entry.get("query", "")
        client = entry.get("client", "unknown")

        # Check known bad substrings
        for pat in THREAT_PATTERNS:
            if pat in domain.lower():
                threat_detected.labels(client=client, domain=domain, indicator=pat).inc()

        # DGA heuristic
        if DGA_RE.match(domain.lower()):
            threat_detected.labels(client=client, domain=domain, indicator="dga_heuristic").inc()


def poll_loop():
    """Background thread: refresh metrics every REFRESH seconds."""
    while True:
        update_stats()
        check_threats()
        time.sleep(REFRESH)


class MetricsHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/metrics":
            self.send_response(200)
            self.send_header("Content-Type", CONTENT_TYPE_LATEST)
            self.end_headers()
            self.wfile.write(generate_latest(registry))
        elif self.path == "/health":
            self.send_response(200)
            self.send_header("Content-Type", "text/plain")
            self.end_headers()
            self.wfile.write(b"ok\n")
        else:
            self.send_response(404)
            self.end_headers()

    def log_message(self, format, *args):
        # suppress default HTTP logging
        pass


def main():
    port = int(os.environ.get("EXPORTER_PORT", "9187"))
    addr = os.environ.get("EXPORTER_ADDR", "127.0.0.1")

    # start background poller
    t = threading.Thread(target=poll_loop, daemon=True)
    t.start()

    server = HTTPServer((addr, port), MetricsHandler)
    print(f"technitium-exporter listening on http://{addr}:{port}/metrics", file=sys.stderr)
    server.serve_forever()


if __name__ == "__main__":
    main()
