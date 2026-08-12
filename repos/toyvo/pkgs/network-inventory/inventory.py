#!/usr/bin/env python3
"""
Network Device Inventory Collector

Collects device data from:
  • Linux ARP table  (ip neigh show)
  • Kea DHCP4 leases  (/var/lib/kea/dhcp4.leases)
  • Technitium DNS client stats (optional, via API)

Writes Prometheus textfile metrics to the given output path.

Metrics written:
  network_device_info{ip="...",mac="...",hostname="...",vendor="...",source="..."} 1
  network_device_last_seen_timestamp{ip="..."} <unix_ts>
  network_device_count   <gauge>
"""

import csv
import os
import re
import subprocess
import sys
import time

from prometheus_client import CollectorRegistry, Gauge, write_to_textfile

OUTPUT = os.environ.get("INVENTORY_OUTPUT", "/var/lib/alloy/textfiles/network_inventory.prom")
KEA_LEASES = os.environ.get("KEA_LEASES", "/var/lib/kea/dhcp4.leases")
TECH_URL = os.environ.get("TECHNITIUM_URL", "")
API_TOKEN = os.environ.get("TECHNITIUM_API_TOKEN", "")
TOKEN_FILE = os.environ.get("TECHNITIUM_TOKEN_FILE", "")
if not API_TOKEN and TOKEN_FILE:
    try:
        with open(TOKEN_FILE, "r") as f:
            API_TOKEN = f.read().strip()
    except Exception:
        pass

# ---------------------------------------------------------------------------
# OUI lookup helpers (simple vendor fingerprinting from MAC prefix)
# ---------------------------------------------------------------------------
OUI_HINTS = {
    "70:85:c2": "Realtek / MSI",
    "4c:20:b8": "Apple",
    "d4:be:dc": "Amazon",
    "d0:12:55": "Samsung",
    "1c:1e:e3": "Espressif / IoT",
    "7c:2b:e1": "Intel",
    "10:27:f5": "TP-Link",
    "30:9c:23": "Realtek",
    "00:e0:67": "Protectli",
    "e4:5f:01": "Raspberry Pi",
    "dc:a6:32": "Raspberry Pi",
    "68:fe:f7": "Intel",
    "b4:6b:fc": "Intel",
    "b4:8c:9d": "Valve / Steam",
    "be:7f:95": "Apple (randomized)",
    "7a:22:0c": "Google (randomized)",
    "3e:ef:ce": "Apple (randomized)",
    "b2:88:66": "Apple (randomized)",
    "8c:fd:f0": "Intel",
}


def vendor_from_mac(mac: str) -> str:
    prefix = mac[:8].lower()
    return OUI_HINTS.get(prefix, "Unknown")


def parse_arp():
    """Return list of dicts from `ip neigh show`."""
    devices = []
    try:
        out = subprocess.check_output(["ip", "neigh", "show"], text=True, timeout=10)
    except Exception:
        return devices

    for line in out.splitlines():
        # e.g.  "10.1.0.100 dev eno1 lladdr d4:be:dc:5d:84:99 REACHABLE"
        m = re.match(
            r"^(\d+\.\d+\.\d+\.\d+)\s+dev\s+\S+\s+lladdr\s+([0-9a-fA-F:]+)\s+(\S+)",
            line,
        )
        if not m:
            continue
        ip, mac, state = m.groups()
        devices.append({
            "ip": ip,
            "mac": mac.lower(),
            "hostname": "",
            "vendor": vendor_from_mac(mac),
            "source": "arp",
            "state": state,
        })
    return devices


def parse_kea():
    """Return list of dicts from Kea CSV lease file."""
    devices = []
    if not os.path.exists(KEA_LEASES):
        return devices

    try:
        with open(KEA_LEASES, "r") as fh:
            reader = csv.DictReader(fh)
            for row in reader:
                ip = row.get("address", "").strip()
                mac = row.get("hwaddr", "").strip().lower()
                hostname = row.get("hostname", "").strip()
                if not ip:
                    continue
                devices.append({
                    "ip": ip,
                    "mac": mac,
                    "hostname": hostname,
                    "vendor": vendor_from_mac(mac),
                    "source": "kea",
                    "state": "leased",
                })
    except Exception:
        pass
    return devices


def parse_technitium():
    """Return list of dicts from Technitium /api/stats client list."""
    devices = []
    if not TECH_URL:
        return devices

    try:
        import requests
        headers = {}
        if API_TOKEN:
            headers["Authorization"] = f"Bearer {API_TOKEN}"
        r = requests.get(f"{TECH_URL}/api/stats", headers=headers, timeout=10)
        r.raise_for_status()
        data = r.json()
        clients = data.get("stats", {}).get("clientQueries", {})
        for ip, _ in clients.items():
            devices.append({
                "ip": ip,
                "mac": "",
                "hostname": "",
                "vendor": "",
                "source": "technitium",
                "state": "active",
            })
    except Exception:
        pass
    return devices


def merge_devices(device_lists):
    """Merge multiple device lists, keyed by IP, keeping the richest record."""
    merged = {}
    for dev_list in device_lists:
        for dev in dev_list:
            ip = dev["ip"]
            existing = merged.get(ip)
            if not existing:
                merged[ip] = dev
                continue
            # Keep non-empty fields from any source
            for key in ("mac", "hostname", "vendor"):
                if dev.get(key) and not existing.get(key):
                    existing[key] = dev[key]
            # Prefer kea/arp source labels over technitium when available
            if dev["source"] in ("kea", "arp"):
                existing["source"] = dev["source"]
            existing["state"] = dev.get("state", existing.get("state", ""))
    return merged


def write_metrics(devices):
    registry = CollectorRegistry()

    info = Gauge(
        "network_device_info",
        "Known network device",
        ["ip", "mac", "hostname", "vendor", "source"],
        registry=registry,
    )
    last_seen = Gauge(
        "network_device_last_seen_timestamp",
        "Unix timestamp of last inventory collection",
        ["ip"],
        registry=registry,
    )
    count = Gauge(
        "network_device_count",
        "Total known devices",
        registry=registry,
    )

    now = time.time()
    for ip, dev in devices.items():
        info.labels(
            ip=ip,
            mac=dev.get("mac", ""),
            hostname=dev.get("hostname", ""),
            vendor=dev.get("vendor", ""),
            source=dev.get("source", ""),
        ).set(1)
        last_seen.labels(ip=ip).set(now)

    count.set(len(devices))

    os.makedirs(os.path.dirname(OUTPUT), exist_ok=True)
    write_to_textfile(OUTPUT, registry)


def main():
    arp = parse_arp()
    kea = parse_kea()
    tech = parse_technitium()

    merged = merge_devices([arp, kea, tech])
    write_metrics(merged)

    print(f"Inventory: {len(merged)} devices written to {OUTPUT}", file=sys.stderr)


if __name__ == "__main__":
    main()
