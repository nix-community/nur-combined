#!/usr/bin/env python3
"""Check the installed CurseForge GUI and agent under xvfb-run with xdotool available."""

import argparse
import os
import signal
import subprocess
import sys
import tempfile
import time
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("launcher", type=Path)
    parser.add_argument("expected_version")
    args = parser.parse_args()
    launcher = args.launcher.resolve(strict=True)
    failure = None

    with tempfile.TemporaryDirectory(prefix="curseforge-smoke-") as temporary:
        root = Path(temporary)
        env = os.environ.copy()
        for name, directory in {
            "HOME": "home",
            "XDG_CACHE_HOME": "cache with spaces",
            "XDG_CONFIG_HOME": "config",
            "XDG_DATA_HOME": "data",
            "XDG_STATE_HOME": "state",
        }.items():
            path = root / directory
            path.mkdir(mode=0o700)
            env[name] = str(path)

        log = root / "startup.log"
        with log.open("wb") as output:
            gui = subprocess.Popen(
                [str(launcher), "--ozone-platform=x11"], env=env,
                stdout=output, stderr=subprocess.STDOUT, start_new_session=True,
            )

        def check_ready():
            if gui.poll() is not None:
                raise RuntimeError(f"GUI exited prematurely with status {gui.returncode}")
            text = log.read_text(errors="replace")
            for marker in (
                "cannot open shared object file",
                "couldn't find a valid icu package",
                "process terminated",
            ):
                if marker in text.lower():
                    raise RuntimeError(f"Startup log contains {marker!r}")
            window = subprocess.run(
                ["xdotool", "search", "--onlyvisible", "--class", "[Cc]urse[Ff]orge"],
                check=False, env=env, capture_output=True, text=True, timeout=5,
            )
            if window.returncode not in (0, 1):
                raise RuntimeError(f"xdotool failed: {window.stderr.strip()}")
            agent_running = False
            for entry in Path("/proc").iterdir():
                if not entry.name.isdecimal():
                    continue
                try:
                    # Restrict the match to this launch so another running app cannot satisfy the check.
                    if os.getsid(int(entry.name)) != gui.pid:
                        continue
                    command = (entry / "cmdline").read_bytes().split(b"\0")[0]
                    if command.rsplit(b"/", 1)[-1] == b"Curse.Agent.Host":
                        agent_running = True
                        break
                except (FileNotFoundError, PermissionError, ProcessLookupError):
                    # Processes can exit between listing /proc and inspecting their command line.
                    continue
            version = args.expected_version.replace("-", ".")
            return (
                window.returncode == 0 and bool(window.stdout.strip()) and agent_running
                and f"[BackgroundController] App version: {version}." in text
                and "Connected to mods agent." in text
            )

        try:
            deadline = time.monotonic() + 60
            while not check_ready():
                if time.monotonic() >= deadline:
                    raise RuntimeError("App not ready within 60s: expected version, visible window, "
                                       "and a connected, running Mods Agent")
                time.sleep(0.25)
            deadline = time.monotonic() + 5
            while time.monotonic() < deadline:
                if not check_ready():
                    raise RuntimeError("GUI or Mods Agent stopped after becoming ready")
                time.sleep(0.25)
        except (OSError, RuntimeError, subprocess.SubprocessError) as error:
            failure = str(error)
        finally:
            # The launcher can exit before its children; always terminate the entire launch group.
            for sig in (signal.SIGTERM, signal.SIGKILL):
                try:
                    os.killpg(gui.pid, sig)
                except ProcessLookupError:
                    pass
                if sig == signal.SIGTERM:
                    time.sleep(1)
            gui.wait(timeout=10)
            if failure is not None:
                print(f"FAIL: {failure}", file=sys.stderr)
                print(log.read_text(errors="replace"), file=sys.stderr)

    if failure is not None:
        return 1
    print("PASS: expected version, visible GUI, connected Mods Agent, startup stability")
    return 0


if __name__ == "__main__":
    sys.exit(main())
