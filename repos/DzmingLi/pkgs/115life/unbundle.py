"""Convert the vendor's self-contained app to use the nixpkgs .NET runtime."""

import json
import sys
from pathlib import Path

app = Path(sys.argv[1])
deps_path = app / "Life115.deps.json"
deps = json.loads(deps_path.read_text())
runtime_prefix = "runtimepack.Microsoft.NETCore.App.Runtime."
removed_runtime = False

for packages in deps["targets"].values():
    for name in list(packages):
        if name.startswith(runtime_prefix):
            runtime = packages.pop(name)
            for kind in ("runtime", "native"):
                for filename in runtime.get(kind, {}):
                    (app / filename).unlink()
            removed_runtime = True
    for package in packages.values():
        dependencies = package.get("dependencies", {})
        for name in list(dependencies):
            if name.startswith(runtime_prefix):
                del dependencies[name]

assert removed_runtime, "Vendor runtime manifest changed; review unbundling"
for name in list(deps["libraries"]):
    if name.startswith(runtime_prefix):
        del deps["libraries"][name]
deps_path.write_text(json.dumps(deps, indent=2) + "\n")

config_path = app / "Life115.runtimeconfig.json"
config = json.loads(config_path.read_text())
options = config["runtimeOptions"]
assert options["tfm"] == "net10.0", "Review the nixpkgs runtime version"
framework, = options.pop("includedFrameworks")
assert framework["name"] == "Microsoft.NETCore.App"
options["framework"] = framework
options["configProperties"].pop("System.Globalization.AppLocalIcu")
config_path.write_text(json.dumps(config, indent=2) + "\n")

# ICU comes from the nixpkgs runtime; SQLitePCLRaw can use system SQLite.
for library in app.glob("libicu*.so.*"):
    library.unlink()
(app / "libe_sqlite3.so").unlink()
(app / "Life115").unlink()
