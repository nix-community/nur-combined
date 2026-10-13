#!/usr/bin/env python3
"""Read-only smoke checks of REA's bundled Linux toolchain; no target execution."""

import importlib.metadata
import json
import os
from pathlib import Path
import subprocess
import sys
import zipfile

checks = []


def check(name, action):
    try:
        detail = action()
        checks.append({"name": name, "ok": True, "detail": detail})
    except Exception as error:
        checks.append({"name": name, "ok": False, "detail": str(error)})


def command(variable, arguments, prefix=None):
    selected = os.environ[variable]
    result = subprocess.run([selected, *arguments], text=True, capture_output=True,
                            timeout=30, check=True)
    output = (result.stdout + result.stderr).strip()
    if prefix is not None and not output.startswith(prefix):
        raise ValueError(f"Unsupported {variable} version: {output}")
    return output[:1000]


def archive(variable):
    selected = Path(os.environ[variable])
    with zipfile.ZipFile(selected) as jar:
        if not any(name.endswith(".class") for name in jar.namelist()):
            raise ValueError(f"No compiled Java classes in {selected}")
    return str(selected)


check("ghidra", lambda: subprocess.run(
    [sys.argv[1], "doctor", "--provider", "ghidra", "--json"],
    text=True, capture_output=True, timeout=30, check=True).stdout[:1000])
for name, variable, args, prefix in [
    ("chromium", "REA_BROWSER_EXECUTABLE", ["--version"], None),
    ("adb", "REA_ADB_PATH", ["version"], None),
    ("apktool", "REA_APKTOOL_COMMAND", ["--version"], None),
    ("ilspycmd", "REA_ILSPY_CMD_PATH", ["--version"], None),
    ("binwalk", "REA_BINWALK_COMMAND", ["--version"], "binwalk 3.1."),
    ("unblob", "REA_UNBLOB_COMMAND", ["--version"], "26.6."),
    ("mitmproxy", "REA_MITMDUMP_COMMAND", ["--version"], "Mitmproxy: 12.2.3"),
    ("wakaru", "REA_WAKARU_COMMAND", ["--version"], None),
]:
    check(name, lambda v=variable, a=args, p=prefix: command(v, a, p))
check("jadx-mcp-jar", lambda: archive("REA_JADX_MCP_JAR"))
check("nativeaot-jar", lambda: archive("REA_BUNDLED_NATIVEAOT_JAR"))
for name, version in [("pwntools", "4.15.0"), ("pyelftools", "0.33"), ("unicorn", "2.1.2")]:
    def verify_distribution(n=name, expected=version):
        observed = importlib.metadata.version(n)
        if observed != expected:
            raise ValueError(f"Expected {expected}, found {observed}")
        return observed
    check(name, verify_distribution)
check("pwndbg", lambda: command("REA_PWNDBG_GDB", [
    "-nx", "-nh", "--batch", "--quiet", "-ex",
    "python from pwndbginit.gdbinit import main_try; main_try()", "-ex",
    "python import pwndbg.lib.version; assert pwndbg.lib.version.__version__.startswith('2026.09.15')",
]))
for variable in ["REA_FIRMWARE_PRLIMIT_COMMAND", "REA_JAVASCRIPT_PRLIMIT_COMMAND", "REA_EVM_PRLIMIT_COMMAND"]:
    check(variable, lambda v=variable: command(v, ["--version"]))
print(json.dumps({"ok": all(c["ok"] for c in checks), "checks": checks}, indent=2))
sys.exit(0 if all(c["ok"] for c in checks) else 1)
