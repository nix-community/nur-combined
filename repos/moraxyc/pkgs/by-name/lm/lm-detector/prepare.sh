#!/usr/bin/env bash

set -euo pipefail

cd "${FETCHRIX_SOURCE:?}"

python3 - <<'PY'
import json
from pathlib import Path

root_pkg = json.loads(Path("package.json").read_text())
cli_pkg = json.loads(Path("cli/package.json").read_text())
shared_pkg = json.loads(Path("shared/package.json").read_text())

root_pkg.pop("workspaces", None)
root_pkg.pop("devDependencies", None)
deps = dict(root_pkg.get("dependencies", {}))
for pkg in (cli_pkg, shared_pkg):
    for name, ver in pkg.get("dependencies", {}).items():
        if not str(ver).startswith("workspace:"):
            deps[name] = ver
root_pkg["dependencies"] = dict(sorted(deps.items()))

Path("package.json").write_text(json.dumps(root_pkg, indent=2) + "\n")
PY

npm install --package-lock-only --ignore-scripts --no-audit --no-fund
