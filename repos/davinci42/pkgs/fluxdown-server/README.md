# FluxDown Server

[Upstream](https://github.com/zerx-lab/FluxDown) binaries for x86_64-linux and
aarch64-linux: `fluxdown-agent`, `fluxdownd` and the embedded Web UI.

## Usage

```sh
nix build -f . fluxdown-server
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

Put `FLUXDOWN_TOKEN=<access-key>` in the environment file (mode `0600`, outside
the Nix store), or complete first-run setup in the Web UI. Configure authentication
before opening access; use a TLS reverse proxy for remote access.

## Settings

```nix
services.fluxdown.settings = {
  upload_limit_bytes = 1048576;
  max_concurrent_tasks = 3;
  bt_enable_upnp = false;
};
```

Declared settings are reapplied on startup; omitted settings remain unmanaged.
Removing a setting does not reset its saved value. `auto_resume_on_start = true`
resumes all paused tasks. Put secret settings in `settingsFile`, a runtime JSON
file readable by `fluxdown`, outside the Nix store.

## Maintenance and tests

```sh
nix-shell
just update fluxdown-server
just contract fluxdown-server
just check fluxdown-server
```

Checks include Nix evaluation, isolated RPC tests and lint. Configuration comes
from upstream `native/protocol/src/daemon_config.rs`; regenerate
`settings-schema.json` through the updater, not by hand. Review contract changes
before running `just update-reviewed fluxdown-server <version>`.

Optional VM test (run only when requested):

```sh
nix-build ./tests/pkgs/fluxdown/vm.nix --no-out-link
```
