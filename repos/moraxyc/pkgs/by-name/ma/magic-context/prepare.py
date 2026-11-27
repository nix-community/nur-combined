#!/usr/bin/env python3
"""Reduce the bun workspace to what the CLI and Pi builds need, for npm-lock."""

import json
import os
from pathlib import Path

root = Path(os.environ["FETCHRIX_SOURCE"])

# The Pi bundle compiles sources from packages/plugin, so its runtime
# dependencies must be installed; tests, dashboard, docs and e2e are not built.
workspaces = ["packages/cli", "packages/plugin", "packages/pi-plugin"]
# Bundled into the Pi extension; every other devDependency is for tests or typechecks.
build_dev_dependencies = {"@huggingface/transformers", "typebox"}


def rewrite(path, edit):
    data = json.loads(path.read_text())
    edit(data)
    path.write_text(json.dumps(data, indent=2) + "\n")


def keep_build_dev_dependencies(data):
    dev = data.get("devDependencies", {})
    data["devDependencies"] = {k: v for k, v in dev.items() if k in build_dev_dependencies}


rewrite(root / "package.json", lambda data: data.update(workspaces=workspaces))
for workspace in workspaces:
    rewrite(root / workspace / "package.json", keep_build_dev_dependencies)
