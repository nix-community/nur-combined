"""Check the real launcher, generated desktop entries and GIO TLS backend."""

import ctypes
import os
from pathlib import Path
import signal
import subprocess
import sys
import tempfile
import time

package, gio_library = sys.argv[1:]
with tempfile.TemporaryDirectory(prefix="115life-check-") as directory:
    home = Path(directory)
    data = home / ".local/share"
    config = home / ".config"
    desktop = data / "applications/life115.desktop"
    autostart = config / "autostart/life115.desktop"
    # Simulate files left behind by an older package output.
    for path in (desktop, autostart):
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(
            "[Desktop Entry]\nType=Application\nName=115 Life\n"
            'Exec="/nix/store/old-115life/bin/115life"\n'
            "X-GNOME-Autostart-enabled=true\n"
        )
    runtime = home / "runtime"
    runtime.mkdir(mode=0o700)
    environment = os.environ | {
        "HOME": directory,
        "XDG_CONFIG_HOME": str(config),
        "XDG_DATA_HOME": str(data),
        "XDG_CACHE_HOME": str(home / ".cache"),
        "XDG_RUNTIME_DIR": str(runtime),
        "GDK_BACKEND": "wayland",
        "APPIMAGE": "/nix/store/old-115life/bin/115life",
    }
    environment.pop("DBUS_SESSION_BUS_ADDRESS", None)
    log_path = home / "app.log"
    with log_path.open("w+") as log:
        process = subprocess.Popen(
            [f"{package}/bin/115life"],
            env=environment,
            cwd=home,
            stdout=log,
            stderr=subprocess.STDOUT,
            start_new_session=True,
        )
        try:
            deadline = time.monotonic() + 30
            while not (
                'Exec="115life" %U\n' in desktop.read_text()
                and 'Exec="115life" --autostart\n' in autostart.read_text()
            ):
                if process.poll() is not None or time.monotonic() > deadline:
                    raise AssertionError("Desktop integration failed:\n" + log_path.read_text())
                time.sleep(0.1)

            subprocess.run(["desktop-file-validate", str(desktop)], check=True)
            actual = dict(
                entry.split("=", 1)
                for entry in Path(f"/proc/{process.pid}/environ").read_text().split("\0")
                if "=" in entry
            )
            assert actual["GDK_BACKEND"] == "x11"
            os.environ["GIO_EXTRA_MODULES"] = actual["GIO_EXTRA_MODULES"]
            gio = ctypes.CDLL(gio_library)
            gio.g_tls_backend_get_default.restype = ctypes.c_void_p
            gio.g_tls_backend_supports_tls.argtypes = [ctypes.c_void_p]
            assert gio.g_tls_backend_supports_tls(gio.g_tls_backend_get_default()), "GIO TLS unavailable"
        finally:
            if process.poll() is None:
                os.killpg(process.pid, signal.SIGTERM)
            try:
                process.wait(timeout=5)
            except subprocess.TimeoutExpired:
                os.killpg(process.pid, signal.SIGKILL)
                process.wait()
