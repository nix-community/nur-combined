# FluxDown Server

Pinned binaries for `x86_64-linux` and `aarch64-linux`: `fluxdown-agent`,
`fluxdownd`, and the embedded Web UI, without the desktop GUI.

## Usage

Build from the repository root:

```sh
nix-build . -A fluxdown-server --no-out-link
```

Adjust the module import path for your configuration:

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
in its `downloads` subdirectory; analytics and mDNS disabled.

The optional environment file can set `FLUXDOWN_TOKEN=<access-key>`. Keep it
outside the Nix store with mode `0600`. Keys require 8–128 visible ASCII characters,
including letters and digits. Without a key, the Web UI offers first-run setup;
there is no Web username or LAN authentication bypass.

For LAN access, set `listenAddress = "0.0.0.0"; openFirewall = true;`.
The firewall rule opens the port globally, not just to LAN clients. Initialize
authentication before exposure; use HTTPS with WebSocket forwarding remotely.
Bracket IPv6 addresses, for example `[::1]`.

## Configuration

Module options: `enable`, `package`, `listenAddress`, `port`, `openFirewall`,
`environment`, `environmentFile`, `settings`, and `settingsFile`.

| Environment variable | Purpose |
| --- | --- |
| `FLUXDOWN_SAVE_DIR` | Initial download directory; saved settings take precedence |
| `FLUXDOWN_DATABASE_URL` | SQLite/PostgreSQL URL; keep credentials in the environment file |
| `FLUXDOWN_WEBROOT` | Static directory replacing the embedded Web UI |
| `FLUXDOWN_TOKEN` / `FLUXDOWN_TOKEN_FORCE` | Seed the key; force `1` replaces it on each start |
| `FLUXDOWN_LANG` | Fallback language: `en` or `zh` |
| `FLUXDOWN_MDNS` / `FLUXDOWN_LINK_NAME` | Discovery and device name |
| `FLUXDOWN_ANALYTICS` | Anonymous analytics |
| `FLUXDOWN_LOG_LEVEL` / `RUST_LOG` | Logging; `RUST_LOG` takes precedence |
| `FLUXDOWN_DEMO` / `FLUXDOWN_DEMO_URL` | Demo mode and permitted URL |

Do not override module-managed `FLUXDOWN_BIND` or `FLUXDOWN_DATA_DIR` in runtime
files. Custom download directories must be writable by `fluxdown`; home
directories are inaccessible by default.

### Daemon settings

`services.fluxdown.settings` exposes writable upstream `DAEMON_CONFIG_FIELDS`.
The generated `settings-schema.json` defines types, bounds, enums, and upstream
defaults. Unknown and read-only keys are rejected.

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

- Speed limits use bytes/second; zero means unlimited.
- All settings default to `null` (unmanaged), not upstream defaults. Declared
  values are reapplied through RPC on each start, overwriting Web UI changes.
  Removing a key leaves its stored value; set its upstream default to reset it.
- Changing `default_save_dir` does not move existing downloads.
- Effective `auto_resume_on_start = true` resumes **all** paused tasks after
  applying settings, even unchanged settings and manually paused tasks. Set it
  to false to disable this extra resume step.

Put secrets in `settingsFile`, an absolute path to a runtime JSON object using
the same keys and types. It must be readable by the service user, unlike
`environmentFile`; for agenix, use owner `fluxdown` and mode `0400`. Do not
duplicate keys across `settings` and `settingsFile`.

The helper uses the local agent token, not a Web UI key or direct database edits.
It retries startup and revision conflicts, then fails startup if settings cannot
be applied. Upstream also checks semantics such as component mirror URLs.
Agent/UI preferences, cloud accounts, queues, and RSS are not managed here.

## Maintenance

Use the [shared workflow](../../README.md#local-maintenance) in `nix-shell`
with authenticated `gh`:

```sh
just update fluxdown-server
just contract fluxdown-server
just check fluxdown-server
```

Verify both architecture hashes and sibling executables with an embedded Web UI.
The four-hour monitor requires both Linux archives and `SHA256SUMS-server.txt`
before validation. It checks Server readiness, not desktop/mobile/Docker or the
checksum manifest contents. Contract changes require review, then
`just update-reviewed fluxdown-server <version>`.

Configuration authorities at the packaged tag in
[upstream](https://github.com/zerx-lab/FluxDown):

| Source | Authority |
| --- | --- |
| `native/protocol/src/daemon_config.rs` | Daemon keys, types, defaults, bounds |
| `native/protocol/src/settings.rs` | Synchronized settings, not all preferences |
| `native/agent/src/server_mode.rs` | Server startup and access-key validation |
| `native/agent/src/runtime.rs`, `native/daemon/src/config.rs` | Component startup |
| `native/agent/src/gateway.rs`, `native/protocol/src/rpc.rs` | Persistent-setting RPCs |

Compare a candidate without writing files:

```sh
python3 pkgs/fluxdown-server/update-settings.py --check --ref <tag>
```

Omit `--ref` to check the packaged release. Catalog, validation-source, or
RPC-source drift prints a diff and fails; unknown catalog syntax also fails.
Managed settings require the package and schema versions to match. This contract
does not cover every upstream configuration surface.

`just check` includes Nix evaluation and isolated RPC tests, without a VM.
For evaluation only:

```sh
nix-instantiate --eval --strict --expr 'import ./tests/eval.nix {}'
```

Optional VM test: `nix-build ./tests/fluxdown.nix`. It checks startup, Web UI,
key persistence, and shutdown; first-run dependencies can be large.
