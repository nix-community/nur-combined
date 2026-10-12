# changedetection.io

Python package based on [nixpkgs PR #569349](https://github.com/NixOS/nixpkgs/pull/569349)
and [upstream](https://github.com/dgtlmoon/changedetection.io), using the caller's
nixpkgs dependencies. Supports x86_64-linux, aarch64-linux and aarch64-darwin.

## Usage

```sh
nix build -f . changedetection-io
./result/bin/changedetection.io -d ./datastore
```

Use the existing NixOS service module, with no additional NUR options:

```nix
{ pkgs, ... }:
{
  services.changedetection-io = {
    enable = true;
    package = (import /path/to/nur-packages { inherit pkgs; }).changedetection-io;
    listenAddress = "127.0.0.1";
  };
}
```

Browser monitoring needs a separate browser backend. Keep credentials outside
the Nix store and back up the datastore before upgrading.

## Maintenance and tests

```sh
nix-shell --run 'just update changedetection-io'
nix-shell --run 'just check changedetection-io'
```

Checks cover the build, runtime dependencies, installed imports, package wiring
and lint. Installed-package checks exercise JSON serialization and selection,
XPath, LLM settings validation, greenlet/gevent, Engine.IO backends, timestamp
formatting and rejection of external XML parameter entities. Upstream unit tests
are not run.

The package uses the caller's Python dependencies and relaxes reviewed version
pins where the application still uses compatible APIs. The additional relaxations
for elementpath, greenlet, jsonpath-ng, orjson, pydantic and python-engineio retain
the previously working dependency versions and are covered by the installed
checks. They do not promise every feature of the newer dependency releases.

The lxml minimum is not relaxed: versions below 6.1.3 lack an external parameter
entity security fix. The package supplies 6.1.3 when needed and rewires its runtime
consumers to use the same lxml. A caller providing 6.1.3 or newer keeps its version.
Review this fallback and the compatibility checks when updating dependencies.

`requirements.txt` and `setup.py` are compared against the reviewed source pinned
in `tests/pkgs/changedetection-io.nix`. Any change prints a diff and fails the
check, including relaxed or removed dependencies. Review the diff, adjust the
package, then update `reviewedSource` and rerun `just check changedetection-io`.
The comparison is file-level, so comment-only changes also require review.
