# FluxDown Server

Pinned upstream binaries for `x86_64-linux` and `aarch64-linux`, including
`fluxdown-agent`, `fluxdownd`, and the embedded Web UI, but not the desktop GUI.

## Usage

Run commands from the repository root. Adjust the import path to your configuration:

```sh
nix-build . -A fluxdown-server --no-out-link
```

```nix
{
  imports = [ ./modules/fluxdown.nix ];
  services.fluxdown = {
    enable = true;
    environmentFile = "/run/secrets/fluxdown.env";
    environment.FLUXDOWN_LANG = "en";
  };
}
```

Defaults: `127.0.0.1:17800`, user `fluxdown`, state `/var/lib/fluxdown`, downloads
in its `downloads` subdirectory. Analytics and mDNS are disabled.

The optional environment file may contain `FLUXDOWN_TOKEN=<access-key>`; keep it
outside the Nix store with mode `0600`. Keys need 8 to 128 visible ASCII characters,
including letters and digits. Without a key, the Web UI opens first-run setup.
There is no Web username or LAN authentication bypass.

For LAN access, set `listenAddress = "0.0.0.0"; openFirewall = true;`.
This opens the port globally, not just to LAN clients. Initialize authentication
before exposure; use HTTPS and WebSocket forwarding for remote access.
Use brackets for IPv6 addresses, such as `[::1]`.

## Configuration

The module exposes `enable`, `package`, `listenAddress`, `port`, `openFirewall`,
`environment`, `environmentFile`, `settings`, and `settingsFile`. Additional startup settings:

| Variable | Purpose |
| --- | --- |
| `FLUXDOWN_SAVE_DIR` | Seed the initial download directory; saved settings take precedence |
| `FLUXDOWN_DATABASE_URL` | SQLite or PostgreSQL connection string; credentials belong in the environment file |
| `FLUXDOWN_WEBROOT` | Replace the embedded Web UI with a static directory |
| `FLUXDOWN_TOKEN` / `FLUXDOWN_TOKEN_FORCE` | Seed the key; force replaces it on each start when set to `1` |
| `FLUXDOWN_LANG` | Fallback language: `en` or `zh` |
| `FLUXDOWN_MDNS` / `FLUXDOWN_LINK_NAME` | Discovery and device name |
| `FLUXDOWN_ANALYTICS` | Anonymous analytics |
| `FLUXDOWN_LOG_LEVEL` / `RUST_LOG` | Logging; `RUST_LOG` takes precedence |
| `FLUXDOWN_DEMO` / `FLUXDOWN_DEMO_URL` | Demo mode and permitted URL |

Do not override module-managed `FLUXDOWN_BIND` or `FLUXDOWN_DATA_DIR` in runtime
files. Custom download directories must be writable by the service user;
home directories are inaccessible by default.

## Declarative daemon settings

`services.fluxdown.settings` exposes all 57 writable entries from upstream
`DAEMON_CONFIG_FIELDS`: downloads, upload/download limits, concurrency, retries,
BitTorrent, ED2K, proxies, webhooks, component paths, and logging. Types, bounds,
enums, and documented upstream defaults come from `settings-schema.json`,
generated from the packaged release. Read-only fields and unknown keys are rejected.

```nix
services.fluxdown.settings = {
  upload_limit_bytes = 1048576;
  speed_limit_bytes = 0;
  max_concurrent_tasks = 3;
  bt_enable_upnp = false;
  proxy_mode = "none";
  "component.ffmpeg.path" = "/run/current-system/sw/bin/ffmpeg";
};
```

Limits use bytes per second; zero means unlimited. All settings default to `null`,
meaning unmanaged, not the upstream default. Only declared values are reapplied
through the official RPC on each start, including restarts after configuration
changes. Web UI edits to declared keys last until the next restart. Removing a
key leaves its stored value unchanged; explicitly set its upstream default to
reset it. Existing downloads are not moved when `default_save_dir` changes.

When the effective `auto_resume_on_start` is true, the helper calls
`daemon.task.resumeAll` after successfully applying settings, even if no values
changed. This resumes all paused tasks, including manually paused tasks, rather
than only tasks paused by BT session reconfiguration. Explicitly setting it to
false disables this extra resume step.

For passwords or webhook secrets, use `settingsFile`, an absolute path to a
runtime JSON object with the same keys and JSON value types. Make it readable by
the service user (for agenix, set the secret owner to `fluxdown` and mode to
`0400`). Do not duplicate keys between `settings` and `settingsFile`. Unlike
`environmentFile`, the settings helper reads this file as the service user.

The startup helper authenticates using the local agent token, without requiring
a Web UI access key or modifying the database. It retries startup and revision
conflicts, and fails startup if settings cannot be applied. Upstream performs
additional semantic checks, such as validating component mirror URLs.

This covers daemon configuration, not agent/UI preferences such as automatic
update checks, cloud accounts, queues, or RSS subscriptions.

## Maintenance

Follow the package-set `AGENTS.md`. Verify both architecture hashes and that the
two executables remain siblings with an embedded Web UI.

Configuration authorities in [upstream](https://github.com/zerx-lab/FluxDown),
at the packaged tag:

- `native/protocol/src/daemon_config.rs`: daemon keys, types, defaults, bounds.
- `native/protocol/src/settings.rs`: synchronized settings, not all preferences.
- `native/agent/src/server_mode.rs`: server startup and access-key validation.
- `native/agent/src/runtime.rs`, `native/daemon/src/config.rs`: component startup.
- `native/agent/src/gateway.rs`, `native/protocol/src/rpc.rs`: persistent-setting RPCs.

Use the shared maintenance flow in `nix-shell` (requires authenticated `gh`):

```sh
just update fluxdown-server
just contract fluxdown-server
just check fluxdown-server
```

The package's `maintenance.toml` selects flat-archive hash updates, schema
regeneration, Nix evaluation, and isolated RPC tests. Contract changes require
review with `just update-reviewed fluxdown-server <version>`. The lower-level
`python3 pkgs/fluxdown-server/update-settings.py --check` remains available.

To compare a candidate upstream release without writing files, add
`--check --ref <tag>`. Differences in the catalog, validation source, or RPC
protocol source fail the check and print a diff. Unknown catalog syntax also
fails instead of silently dropping options. The module rejects managed settings
when its package version differs from the recorded schema version. This is a
manual contract check; it does not cover every upstream configuration surface.

The six-hour monitor requires both Linux archives and `SHA256SUMS-server.txt`
(upstream's Server completion marker), then runs the shared update validation.
A successful update opens a PR titled `fluxdown-server: old-version -> new-version`
with its checks listed. Contract changes stop for review. Readiness covers Server,
not desktop, mobile, or Docker, and does not verify the checksum manifest contents.

Lightweight regression test:

```sh
nix-instantiate --eval --strict --expr 'import ./tests/eval.nix {}'
```

Runtime validation and isolated RPC integration tests (no VM):

```sh
export FLUXDOWN_TEST_PACKAGE=$(nix build -f . fluxdown-server --no-link --print-out-paths)
nix-shell -p 'python3.withPackages (p: [ p.websocket-client ])' --run 'PYTHONDONTWRITEBYTECODE=1 python3 tests/settings.py -v'
```

Optional VM integration test: `nix-build ./tests/fluxdown.nix`.
It checks startup, Web UI, key persistence, and shutdown; first-run dependencies
can be large.
