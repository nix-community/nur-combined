"""Dashboard listing active omp collab sessions.

Reads the link files written by the omp-collab-linkfile patch
(~/.omp/run/collab-hosts/<pid>.json), prunes dead hosts, renders one
clickable row per live session.
"""

import html
import json
import os
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

HOSTS_DIR = Path(
    os.environ.get("OMP_COLLAB_HOSTS_DIR")
    or os.path.expanduser("~/.omp/run/collab-hosts")
)
PORT = int(os.environ.get("OMP_COLLAB_DASHBOARD_PORT", "80"))
# WireGuard subnet + loopback only: the page hands out room secrets.
ALLOWED_PREFIXES = ("10.100.", "127.", "::1")

PAGE = """<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta http-equiv="refresh" content="15">
<title>omp sessions</title>
<style>
  :root {{ color-scheme: dark; }}
  body {{
    margin: 0; padding: 1rem; background: #1e1e2e; color: #cdd6f4;
    font-family: system-ui, sans-serif;
  }}
  h1 {{ font-size: 1.1rem; color: #89b4fa; margin: 0 0 1rem; }}
  .empty {{ color: #6c7086; margin-top: 2rem; text-align: center; }}
  .card {{
    background: #313244; border-radius: 12px; padding: 0.9rem;
    margin-bottom: 0.8rem;
  }}
  .name {{ font-weight: 600; margin-bottom: 0.15rem; }}
  .meta {{ color: #a6adc8; font-size: 0.8rem; word-break: break-all; }}
  .links {{ margin-top: 0.6rem; display: flex; gap: 0.6rem; }}
  .links a {{
    flex: 1; text-align: center; text-decoration: none; padding: 0.6rem 0;
    border-radius: 8px; font-size: 0.9rem; background: #89b4fa; color: #1e1e2e;
  }}
  .links a.view {{ background: #45475a; color: #cdd6f4; }}
</style>
</head>
<body>
<h1>omp sessions · {count}</h1>
{rows}
</body>
</html>
"""

CARD = """<div class="card">
  <div class="name">{name}</div>
  <div class="meta">{cwd} · {ago}</div>
  <div class="links">
    <a href="{web}">open</a>
    <a class="view" href="{view}">read-only</a>
  </div>
</div>
"""


def pid_alive(pid):
    try:
        os.kill(pid, 0)
    except (TypeError, ProcessLookupError):
        return False
    except PermissionError:
        return True
    return True


def load_sessions():
    sessions = []
    if not HOSTS_DIR.is_dir():
        return sessions
    for link_file in HOSTS_DIR.glob("*.json"):
        try:
            data = json.loads(link_file.read_text())
        except (OSError, ValueError):
            continue
        if not pid_alive(data.get("pid")):
            # Crashed host: the teardown never ran, drop the stale file.
            try:
                link_file.unlink()
            except OSError:
                pass
            continue
        sessions.append(data)
    sessions.sort(key=lambda s: s.get("startedAt") or 0, reverse=True)
    return sessions


def time_ago(started_ms):
    if not started_ms:
        return "?"
    seconds = max(0, int(time.time() - started_ms / 1000))
    if seconds < 3600:
        return f"{seconds // 60}m ago"
    if seconds < 86400:
        return f"{seconds // 3600}h ago"
    return f"{seconds // 86400}d ago"


def shorten_cwd(cwd):
    home = os.path.expanduser("~")
    return cwd.replace(home, "~", 1) if cwd else "?"


def render():
    sessions = load_sessions()
    if not sessions:
        rows = '<div class="empty">No active sessions</div>'
    else:
        rows = "\n".join(
            CARD.format(
                name=html.escape(s.get("sessionName") or "untitled"),
                cwd=html.escape(shorten_cwd(s.get("cwd"))),
                ago=time_ago(s.get("startedAt")),
                web=html.escape(s.get("webLink") or "#", quote=True),
                view=html.escape(s.get("webViewLink") or "#", quote=True),
            )
            for s in sessions
        )
    return PAGE.format(count=len(sessions), rows=rows)


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if not self.client_address[0].startswith(ALLOWED_PREFIXES):
            self.send_error(403)
            return
        body = render().encode()
        self.send_response(200)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, *_args):
        pass


if __name__ == "__main__":
    ThreadingHTTPServer(("0.0.0.0", PORT), Handler).serve_forever()
