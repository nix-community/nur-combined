import json, os, sys, time, urllib.request as u, urllib.parse as p

url = os.environ.get("TECHNITIUM_URL", "http://127.0.0.1:5380")
token_file = os.environ.get("TECHNITIUM_TOKEN_FILE", "")
admin_user = os.environ.get("TECHNITIUM_ADMIN_USER", "admin")
admin_pass_file = os.environ.get("TECHNITIUM_ADMIN_PASS_FILE", "")

# Read files if they exist
def read_file(path):
    if path and os.path.exists(path):
        try:
            with open(path) as f:
                return f.read().strip()
        except Exception as e:
            print(f"Warning: could not read {path}: {e}", file=sys.stderr)
    return ""

token = read_file(token_file)
admin_pass = read_file(admin_pass_file) or "admin"

# ---------------------------------------------------------------------------
# Low-level HTTP helpers
# ---------------------------------------------------------------------------

def request(ep, data=None, method="GET", auth_token=None):
    """Make an API request. Returns parsed JSON dict or None on failure."""
    headers = {}
    if auth_token:
        headers["Authorization"] = "Bearer " + auth_token
    if data:
        body = p.urlencode(data).encode()
        headers["Content-Type"] = "application/x-www-form-urlencoded"
        req = u.Request(url + ep, data=body, headers=headers, method=method)
    else:
        req = u.Request(url + ep, headers=headers, method=method)
    try:
        with u.urlopen(req, timeout=30) as resp:
            return json.loads(resp.read().decode())
    except Exception as e:
        print(f"  HTTP error on {ep}: {e}", file=sys.stderr)
        return None


def is_ok(resp):
    """True if response is a dict with status == 'ok'."""
    return isinstance(resp, dict) and resp.get("status") == "ok"


def is_invalid_token(resp):
    """True if response indicates an auth failure."""
    return isinstance(resp, dict) and resp.get("status") == "invalid-token"


# ---------------------------------------------------------------------------
# Auth: try existing token → admin login → fail
# ---------------------------------------------------------------------------

def get_auth_token():
    """
    Return a working API/session token.
    1. If a token file is provided and works, use it.
    2. Otherwise try admin/admin login.
    3. Otherwise try token-file contents as admin password.
    """
    # 1. Try token file content as a Bearer token
    if token:
        print(f"Trying token from {token_file} ...")
        resp = request("/api/stats", auth_token=token)
        if is_ok(resp):
            print("Token authenticated successfully.")
            return token
        elif is_invalid_token(resp):
            print("Token rejected (invalid-token).")
        else:
            print(f"Token auth failed: {resp}")

    # 2. Try admin password from sops secret (or default "admin")
    print(f"Trying login with {admin_user}/<password-from-file> ...")
    login = request("/api/user/login", {"user": admin_user, "pass": admin_pass}, "POST")
    if is_ok(login) and login.get("token"):
        print("Login successful.")
        return login["token"]
    else:
        print(f"Login failed: {login}")

    print("FATAL: Could not authenticate with Technitium API.", file=sys.stderr)
    print("  - Put the admin password in the sops secret 'technitium_admin_password'.", file=sys.stderr)
    print("  - Or generate an API token via the web UI and save it to the sops secret 'technitium_api_key'.", file=sys.stderr)
    return None


# ---------------------------------------------------------------------------
# Wait for API to be reachable (unauthenticated health check)
# ---------------------------------------------------------------------------

def wait_for_api(max_wait=120):
    """Poll /api/stats without auth until it responds (any response = up)."""
    for i in range(max_wait):
        try:
            req = u.Request(url + "/api/stats", method="GET")
            with u.urlopen(req, timeout=5) as resp:
                # We got any HTTP response — API is up.  We don't care about
                # the JSON body here; auth is handled separately.
                return True
        except Exception:
            pass
        time.sleep(1)
    return False


# ---------------------------------------------------------------------------
# Configuration helpers
# ---------------------------------------------------------------------------

def get_zone_type(t, zone_name):
    """Query zone options to get the zone type. Returns type string or None."""
    r = request(f"/api/zones/options?zone={p.quote(zone_name)}", auth_token=t)
    if is_ok(r) and isinstance(r, dict):
        return r.get("type")
    return None


def zone(t):
    zone_file = os.environ.get("TECHNITIUM_ZONE_RECORDS_FILE", "")
    if not zone_file or not os.path.exists(zone_file):
        print("WARNING: no zone records file found, skipping.", file=sys.stderr)
        return
    with open(zone_file) as f:
        records = json.load(f)

    # Group records by zone and create each primary zone
    zones_created = set()
    for rec in records:
        zone_name = rec.get("zone", "diekvoss.net")
        if zone_name not in zones_created:
            print(f"Creating zone {zone_name} ...")
            r = request("/api/zones/create", {"zone": zone_name, "type": "Primary"}, "POST", t)
            if is_ok(r):
                print(f"  Zone created.")
            elif isinstance(r, dict) and "already exists" in r.get("errorMessage", "").lower():
                print(f"  Zone already exists, continuing.")
            else:
                print(f"  Warning: zone create failed: {r}")
            zones_created.add(zone_name)

    for rec in records:
        name = rec.get("name", "@")
        zone_name = rec.get("zone", "diekvoss.net")
        if name == "@":
            domain = zone_name
        else:
            domain = f"{name}.{zone_name}"
        payload = dict(rec)
        payload["domain"] = domain
        print(f"  Adding record: {domain} {rec.get('type','A')} {rec.get('value','')} ...")
        r = request("/api/zones/records/add", payload, "POST", t)
        if not is_ok(r):
            msg = str(r.get("errorMessage", "")) if isinstance(r, dict) else ""
            if "already exists" in msg.lower() or "duplicate" in msg.lower():
                print(f"    Already exists, skipped.")
            else:
                print(f"    ERROR: {r}")


def forwarder_zones(t):
    fw_file = os.environ.get("TECHNITIUM_FORWARDER_ZONES_FILE", "")
    if not fw_file or not os.path.exists(fw_file):
        print("WARNING: no forwarder zones file found, skipping.", file=sys.stderr)
        return
    with open(fw_file) as f:
        zones = json.load(f)

    for zone_cfg in zones:
        zone_name = zone_cfg.get("zone")
        protocol = zone_cfg.get("protocol", "Udp")
        forwarder = zone_cfg.get("forwarder", "")
        print(f"Creating forwarder zone {zone_name} ...")
        r = request("/api/zones/create", {
            "zone": zone_name,
            "type": "Forwarder",
            "protocol": protocol,
            "forwarder": forwarder,
        }, "POST", t)
        if is_ok(r):
            print(f"  Forwarder zone created.")
        elif isinstance(r, dict) and "already exists" in r.get("errorMessage", "").lower():
            # Check if it's already a forwarder zone
            existing_type = get_zone_type(t, zone_name)
            if existing_type == "Forwarder":
                print(f"  Forwarder zone already exists, continuing.")
            else:
                print(f"  Zone exists as {existing_type}, deleting to recreate as Forwarder...")
                del_r = request("/api/zones/delete", {"zone": zone_name}, "POST", t)
                if is_ok(del_r):
                    r2 = request("/api/zones/create", {
                        "zone": zone_name,
                        "type": "Forwarder",
                        "protocol": protocol,
                        "forwarder": forwarder,
                    }, "POST", t)
                    if is_ok(r2):
                        print(f"  Forwarder zone created after delete.")
                    else:
                        print(f"  Warning: forwarder zone recreate failed: {r2}")
                else:
                    print(f"  Warning: could not delete existing zone: {del_r}")
        else:
            print(f"  Warning: forwarder zone create failed: {r}")


def blocklists(t):
    bl_file = os.environ.get("TECHNITIUM_BLOCKLISTS_FILE", "")
    if not bl_file or not os.path.exists(bl_file):
        print("WARNING: no blocklists file found, skipping.", file=sys.stderr)
        return
    with open(bl_file) as f:
        urls = json.load(f)
    if not urls:
        return
    print("Configuring blocklists ...")
    # Technitium /api/settings/set with blockListUrls overwrites on each call,
    # so send all URLs at once joined by commas.
    combined = ",".join(urls)
    r = request("/api/settings/set", {"blockListUrls": combined}, "POST", t)
    if is_ok(r):
        print(f"  OK: set {len(urls)} blocklist URLs")
    else:
        print(f"  WARNING: could not set blocklists: {r}", file=sys.stderr)
        # Fallback: try one at a time via add endpoints
        endpoints = ["/api/blockList/urls/add", "/api/blockList/urls/set"]
        for block_url in urls:
            print(f"  Adding blocklist: {block_url}")
            added = False
            for ep in endpoints:
                r = request(ep, {"url": block_url}, "POST", t)
                if is_ok(r):
                    print(f"    OK via {ep}")
                    added = True
                    break
                elif isinstance(r, dict) and r.get("status") == "error":
                    msg = r.get("errorMessage", "")
                    if "already exists" in msg.lower() or "duplicate" in msg.lower():
                        print(f"    Already exists, skipped.")
                        added = True
                        break
            if not added:
                print(f"    WARNING: could not add blocklist", file=sys.stderr)


def forwarders(t):
    fw_file = os.environ.get("TECHNITIUM_FORWARDERS_FILE", "")
    if not fw_file or not os.path.exists(fw_file):
        print("WARNING: no forwarders file found, skipping.", file=sys.stderr)
        return
    with open(fw_file) as f:
        fwds = json.load(f)
    if not fwds:
        return
    print("Configuring forwarders ...")
    # Technitium /api/settings/set with forwarders overwrites on each call,
    # so send all forwarders at once joined by commas.
    combined = ",".join(fwds)
    r = request("/api/settings/set", {
        "forwarders": combined,
        "forwarderProtocol": "Quic",
        "concurrentForwarding": "true",
        "forwarderRetries": "3",
        "forwarderTimeout": "2000",
        "forwarderConcurrency": "2",
    }, "POST", t)
    if is_ok(r):
        print(f"  OK: set {len(fwds)} forwarders")
    else:
        print(f"  WARNING: could not set forwarders: {r}", file=sys.stderr)
        # Fallback: try one at a time via add endpoints
        endpoints = ["/api/forwarders/add", "/api/forwarders/set"]
        for fwd in fwds:
            print(f"  Adding forwarder: {fwd}")
            added = False
            for ep in endpoints:
                r = request(ep, {"address": fwd}, "POST", t)
                if is_ok(r):
                    print(f"    OK via {ep}")
                    added = True
                    break
                elif isinstance(r, dict) and r.get("status") == "error":
                    msg = r.get("errorMessage", "")
                    if "already exists" in msg.lower() or "duplicate" in msg.lower():
                        print(f"    Already exists, skipped.")
                        added = True
                        break
            if not added:
                print(f"    WARNING: could not add forwarder", file=sys.stderr)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    print(f"Waiting for Technitium API at {url} ...")
    if not wait_for_api():
        print("FATAL: Technitium API did not become reachable within 120 seconds.", file=sys.stderr)
        sys.exit(1)
    print("API is reachable.")

    t = get_auth_token()
    if not t:
        sys.exit(1)

    zone(t)
    forwarder_zones(t)
    blocklists(t)
    forwarders(t)

    print("Technitium configuration complete.")