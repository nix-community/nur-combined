"""Convergent merge/prune of gryph hooks into agent-owned config files.

Invoked by the gryph Home Manager module's activation script with a JSON spec
generated at evaluation time. Enabled integrations ensure their hooks are
present; disabled ones have their previously installed gryph hooks removed
again. User hooks and settings are never touched.
"""

import json
import os
import re
import sys
from pathlib import Path

MARKER = "# managed-by:gryph-home-module"


def die(message):
    print(f"gryph home module: error: {message}", file=sys.stderr)
    sys.exit(1)


def check_store_symlink(path, hint):
    if path.is_symlink():
        try:
            target = os.readlink(path)
        except OSError:
            return
        if target.startswith("/nix/store"):
            die(
                f"{path} is a Nix store symlink managed by another Home Manager "
                f"module. {hint}"
            )


def write_json(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    text = json.dumps(data, indent=2) + "\n"
    if path.exists():
        path.write_text(text)
    else:
        fd = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
        with os.fdopen(fd, "w") as handle:
            handle.write(text)


def merge_settings(home, name, agent, prefix):
    path = home / agent["path"]
    enabled = agent["enabled"]
    check_store_symlink(
        path,
        f'Inject the read-only programs.gryph.hooks."{name}" value into that '
        f"module's settings instead, or set "
        f'programs.gryph.enableIntegration."{name}" = false.',
    )

    data = {}
    if path.exists():
        try:
            data = json.loads(path.read_text())
        except json.JSONDecodeError as exc:
            die(f"{path} contains invalid JSON ({exc}); refusing to modify it.")
        if not isinstance(data, dict):
            die(f"{path} is not a JSON object; refusing to modify it.")
    elif not enabled:
        return

    existing = data.get("hooks") or {}
    if not isinstance(existing, dict):
        die(f'{path}: "hooks" is not an object; refusing to modify it.')

    # Drop every previously installed gryph hook (identified by the command
    # prefix); user hooks and matchers are preserved as-is.
    cleaned = {}
    for hook_type, matchers in existing.items():
        if not isinstance(matchers, list):
            cleaned[hook_type] = matchers
            continue
        kept_matchers = []
        for matcher in matchers:
            if not isinstance(matcher, dict):
                kept_matchers.append(matcher)
                continue
            hook_list = matcher.get("hooks")
            if not isinstance(hook_list, list):
                kept_matchers.append(matcher)
                continue
            kept_hooks = [
                hook
                for hook in hook_list
                if not (
                    isinstance(hook, dict)
                    and isinstance(hook.get("command"), str)
                    and hook["command"].startswith(prefix)
                )
            ]
            if kept_hooks:
                matcher = dict(matcher)
                matcher["hooks"] = kept_hooks
                kept_matchers.append(matcher)
        if kept_matchers:
            cleaned[hook_type] = kept_matchers

    if enabled:
        for hook_type, matchers in agent["hooks"].items():
            cleaned[hook_type] = cleaned.get(hook_type, []) + matchers
    elif cleaned == existing:
        # Disabled and nothing to prune; leave the user's file untouched.
        return

    if cleaned:
        data["hooks"] = cleaned
    else:
        data.pop("hooks", None)

    if not data and not path.exists():
        return
    write_json(path, data)


def sync_codex_flag(home, codex):
    path = home / codex["path"]
    enabled = codex["enabled"]
    check_store_symlink(
        path,
        "Set programs.gryph.enableIntegration.codex = false and manage "
        "codex_hooks in that module's own configuration.",
    )

    if not path.exists():
        if not enabled:
            return
        path.parent.mkdir(parents=True, exist_ok=True)
        fd = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
        with os.fdopen(fd, "w") as handle:
            handle.write(f"[features]\ncodex_hooks = true {MARKER}\n")
        return

    original = path.read_text()
    lines = original.splitlines(keepends=True)
    section_re = re.compile(r"^\s*\[([^\]]+)\]\s*$")
    flag_re = re.compile(r"^(\s*)codex_hooks\s*=\s*(\w+)(.*)$")

    current_section = None
    features_header = None
    has_true = False
    has_false = False
    out = []

    for line in lines:
        section_match = section_re.match(line)
        if section_match:
            current_section = section_match.group(1).strip()
            if current_section == "features":
                features_header = len(out)
            out.append(line)
            continue
        if current_section == "features":
            flag_match = flag_re.match(line)
            if flag_match:
                value = flag_match.group(2).lower()
                comment = flag_match.group(3)
                if value == "true":
                    has_true = True
                    if not enabled and MARKER in comment:
                        continue  # remove only module-managed lines
                elif value == "false":
                    has_false = True
        out.append(line)

    if enabled and not has_true:
        if has_false:
            print(
                "gryph home module: warning: ~/.codex/config.toml sets "
                "codex_hooks = false; Codex will not run gryph hooks. "
                "Change it to true to enable the integration.",
                file=sys.stderr,
            )
        else:
            flag_line = f"codex_hooks = true {MARKER}\n"
            if features_header is not None:
                out.insert(features_header + 1, flag_line)
            else:
                if out and not out[-1].endswith("\n"):
                    out[-1] += "\n"
                if out and out[-1].strip():
                    out.append("\n")
                out.append("[features]\n")
                out.append(flag_line)

    text = "".join(out)
    if text != original:
        path.write_text(text)


def main():
    spec = json.loads(Path(sys.argv[1]).read_text())
    home = Path.home()
    prefix = spec["hookCommand"]

    for name, agent in spec["agents"].items():
        merge_settings(home, name, agent, prefix)

    sync_codex_flag(home, spec["codex"])


if __name__ == "__main__":
    main()
