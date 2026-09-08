#!/usr/bin/env python3
"""Exercise the installed launcher under xvfb-run with xdotool available."""

import argparse
import json
import os
from pathlib import Path
import re
import signal
import stat
import subprocess
import sys
import tempfile
import time


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("launcher", type=Path)
    parser.add_argument("expected_version")
    args = parser.parse_args()
    launcher = args.launcher.resolve(strict=True)
    processes = []
    logs = []
    failure = None

    # Native TemporaryDirectory cleanup also handles read-only vendor copies.
    with tempfile.TemporaryDirectory(prefix="chatgpt-smoke-") as temporary:
        root = Path(temporary)
        env = os.environ.copy()
        # Do not let launcher overrides route plugin writes into the user's data.
        for name in tuple(env):
            if name.startswith("CODEX_"):
                del env[name]
        for name, directory in {
            "HOME": "home",
            "XDG_CACHE_HOME": "cache with spaces",
            "XDG_CONFIG_HOME": "config",
            "XDG_DATA_HOME": "data",
            "CODEX_HOME": "codex",
            "XDG_STATE_HOME": "state",
        }.items():
            path = root / directory
            path.mkdir(mode=0o700)
            env[name] = str(path)

        def launch(label, *arguments):
            log = root / (label + ".log")
            logs.append(log)
            with log.open("wb") as output:
                process = subprocess.Popen(
                    [str(launcher), *arguments], env=env,
                    stdout=output, stderr=subprocess.STDOUT,
                    start_new_session=True,
                )
            processes.append(process)
            return process, log

        def check_errors():
            for log in logs:
                text = log.read_text(errors="replace")
                for marker in (
                    "cannot open shared object file",
                    "plugin_marketplace_folder_write_failed",
                    "bundled_plugins_marketplace_resolve_failed",
                ):
                    if marker in text.lower():
                        raise RuntimeError(f"{log.name}: {marker}")

        def cache_snapshot():
            cache = Path(env["XDG_CACHE_HOME"]) / "chatgpt-nix"
            entries = list(cache.iterdir())
            payloads = [path for path in entries if path.name != ".lock"]
            if (len(payloads) != 1 or not payloads[0].is_dir()
                    or payloads[0].is_symlink()
                    or not re.fullmatch(r"[0-9a-z]{32}-chatgpt-.+", payloads[0].name)):
                raise RuntimeError(f"Expected one payload directory and no staging leftovers: {entries}")
            payload = payloads[0]
            plugins = payload / "plugins"
            if not plugins.is_dir() or plugins.is_symlink():
                raise RuntimeError("Cached plugins must be a copied directory")
            snapshot = {}
            for path in [plugins, *plugins.rglob("*")]:
                info = path.stat()
                if not info.st_mode & stat.S_IWUSR:
                    raise RuntimeError(f"Plugin entry is not owner writable: {path}")
                snapshot[path.relative_to(cache)] = (info.st_ino, info.st_mtime_ns)
            resources = {path.name: path for path in payload.iterdir() if path.name != "plugins"}
            if not {"codex", "cua_node"} <= resources.keys():
                raise RuntimeError("Cached resources are missing codex or cua_node")
            for path in resources.values():
                if not path.is_symlink() or not path.exists():
                    raise RuntimeError(f"Resource is not a valid symlink: {path}")
            # Compare with the vendor directory so omitted resource links also fail.
            source = resources["codex"].resolve(strict=True).parent
            if {path.name for path in source.iterdir()} != {"plugins", *resources}:
                raise RuntimeError("Cached resource names differ from the vendor resources")
            return snapshot

        try:
            versions = [launch(f"version-{index}", "--version") for index in range(2)]
            deadline = time.monotonic() + 60
            for process, log in versions:
                code = process.wait(timeout=max(0, deadline - time.monotonic()))
                if code != 0 or args.expected_version not in log.read_text().splitlines():
                    raise RuntimeError(f"{log.name}: exit {code}, expected version {args.expected_version}")
            check_errors()
            before = cache_snapshot()
            process, log = launch("version-repeat", "--version")
            code = process.wait(timeout=60)
            if code != 0 or args.expected_version not in log.read_text().splitlines():
                raise RuntimeError(f"{log.name}: exit {code}, expected version {args.expected_version}")
            check_errors()
            if cache_snapshot() != before:
                raise RuntimeError("Repeated --version changed cached plugin inodes or mtimes")

            gui, log = launch("gui", "--ozone-platform=x11")
            deadline = time.monotonic() + 60
            while True:
                check_errors()
                if gui.poll() is not None:
                    raise RuntimeError(f"GUI exited prematurely with status {gui.returncode}")
                text = log.read_text(errors="replace").lower()
                window = subprocess.run(
                    ["xdotool", "search", "--onlyvisible", "--name", "^ChatGPT$"],
                    env=env, capture_output=True, text=True, timeout=5,
                )
                if window.returncode not in (0, 1):
                    raise RuntimeError(f"xdotool failed: {window.stderr.strip()}")
                if (window.returncode == 0 and window.stdout.strip()
                        and "codex cli initialized" in text and "ready-to-show" in text):
                    break
                if time.monotonic() >= deadline:
                    raise RuntimeError("GUI not ready within 60s: expected visible ChatGPT window, "
                                       "Codex CLI initialized, and ready-to-show")
                time.sleep(0.25)
            # This field is written by the app after copying the bundled plugin, not by the launcher.
            manifest = (Path(env["CODEX_HOME"]) / ".tmp/bundled-marketplaces/openai-bundled"
                        / "plugins/visualize/.codex-plugin/plugin.json")
            deadline = time.monotonic() + 60
            while not (manifest.is_file() and "bundledContentVariant" in json.loads(manifest.read_text())):
                check_errors()
                if gui.poll() is not None:
                    raise RuntimeError(f"GUI exited during plugin initialization with status {gui.returncode}")
                if time.monotonic() >= deadline:
                    raise RuntimeError("App did not finish copying and updating the bundled plugin within 60s")
                time.sleep(0.25)

            # Check for delayed failures after the window and plugin initialization are both ready.
            deadline = time.monotonic() + 5
            while time.monotonic() < deadline:
                check_errors()
                if gui.poll() is not None:
                    raise RuntimeError(f"GUI exited prematurely with status {gui.returncode}")
                time.sleep(0.25)
            check_errors()
            cache_snapshot()
        except (OSError, RuntimeError, ValueError, subprocess.SubprocessError) as error:
            failure = str(error)
        finally:
            # Leaders can exit before their children; always signal the session's group.
            for sig in (signal.SIGTERM, signal.SIGKILL):
                for process in processes:
                    try:
                        os.killpg(process.pid, sig)
                    except ProcessLookupError:
                        pass
                if sig == signal.SIGTERM:
                    time.sleep(1)
            for process in processes:
                process.wait()
            if failure is not None:
                print(f"FAIL: {failure}", file=sys.stderr)
                for log in logs:
                    print(f"--- {log.name} ---", file=sys.stderr)
                    print(log.read_text(errors="replace"), file=sys.stderr)

    if failure is not None:
        return 1
    print("PASS: concurrent versions, cache integrity and reuse, GUI and plugin initialization, stability")
    return 0


if __name__ == "__main__":
    sys.exit(main())
