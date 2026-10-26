import concurrent.futures
import json
import subprocess
import sys

sockets = {
    "atuin": ("caddy/egress/atuin", "/"),
    "calibre": ("caddy/egress/calibre", "/"),
    "forgejo": ("caddy/egress/forgejo", "/api/healthz"),
    "grafana": ("caddy/egress/grafana", "/api/health"),
    "immich": ("caddy/egress/immich", "/api/server/ping"),
    "immich-public-proxy": ("caddy/egress/immich-public-proxy", "/"),
    "jellyfin": ("caddy/egress/jellyfin", "/health"),
    "meilisearch": ("caddy/egress/meilisearch", "/health"),
    "misskey": ("caddy/egress/misskey", "/"),
    "pocket-id": ("caddy/egress/pocket-id", "/.well-known/openid-configuration"),
    "synapse": ("caddy/egress/synapse", "/_matrix/client/versions"),
    "vaultwarden": ("caddy/egress/vaultwarden", "/alive"),
    "victoriametrics": ("grafana/egress/victoriametrics", "/health"),
    "ncps-metrics": ("observability/egress/ncps", "/metrics"),
    "seaweedfs-metrics": ("observability/egress/seaweedfs", "/metrics"),
    "synapse-metrics": ("observability/egress/synapse", "/_synapse/metrics"),
    "pocket-id-metrics": ("observability/egress/pocket-id", "/metrics"),
}
checks = {
    name: ["--unix-socket", f"/run/realm/{socket}.sock", f"http://localhost{path}"]
    for name, (socket, path) in sockets.items()
}
checks.update({
    "sept": ["--proxy", "socks5h://127.0.0.1:1905", "https://example.com/"],
    "cloudflared-ready": ["http://127.0.0.1:20241/ready"],
    "public-tunnel": ["https://oidc.nyaw.xyz/.well-known/openid-configuration"],
    "loki-backend": ["--unix-socket", "/run/realm/loki/ingress/http.sock", "http://localhost/metrics"],
    "grafana-local-adapter": ["http://127.0.0.1:13090/health"],
    "telegram-socks": ["--socks5-hostname", "127.0.0.1:11080", "https://example.com/"],
})
namespaces = {
    "grafana-local-adapter": "realm-net-grafana",
    "telegram-socks": "realm-net-mautrix-telegram",
}


def probe(item):
    name, arguments = item
    command = [
        "curl", "--noproxy", "", "--max-time", "15", "-sS",
        "-o", "/dev/null", "-w", "%{http_code}", *arguments,
    ]
    try:
        if name in namespaces:
            pid = subprocess.check_output([
                "systemctl", "show", namespaces[name], "-p", "MainPID", "--value",
            ], text=True, timeout=5).strip()
            if not pid.isdecimal() or int(pid) == 0:
                raise ValueError("The namespace has no running process.")
            command = ["nsenter", "-t", pid, "-n", *command]
        result = subprocess.run(command, capture_output=True, text=True, timeout=20)
        return name, {"exit": result.returncode, "http": result.stdout}
    except (subprocess.SubprocessError, ValueError) as error:
        return name, {"error": str(error)}


with concurrent.futures.ThreadPoolExecutor(max_workers=4) as pool:
    results = dict(pool.map(probe, checks.items()))
print(json.dumps(results, sort_keys=True, indent=2))
sys.exit(0 if all(result == {"exit": 0, "http": "200"} for result in results.values()) else 1)
