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
the Nix store), or complete first-run setup in the Web UI using the one-time
code in `/var/lib/fluxdown/agent/setup-bootstrap`. Configure authentication
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

`completed_record_retention_days` accepts -1 (clean after completion), 0 (never
clean), or 1 through 3650 days. Non-zero values remove eligible completed task
records, not downloaded files; seeding, queued-to-seed, and newly completed
tasks within the 10-second notification grace window are preserved.

`proxy_protocol_{http,ftp,hls,dash,bt,ed2k}` accept `""` (default fallback),
`direct://`, or a proxy URL with an explicit port (`bt` rejects `https://`;
`ed2k` requires `socks5://`). Put URLs containing credentials in `settingsFile`.

`default_segments` accepts 0 (automatic) through 512. Values above 64 can trigger
remote server rate limits; values above 256 carry greater risk. Set
`bt_enable_utp = false` to use TCP-only BitTorrent transport instead of the upstream
TCP/uTP default. Cloud notification reporting requires explicit opt-in in the UI.

`bt_piece_order` (`rarest` or `sequential`) and `bt_first_last_pieces_first`
set defaults for new BT tasks, not existing ones. Setting
`bt_selection_auto_default = false` disables the usual 60-second default file
selection and can leave headless tasks waiting for user input.

`hash_after_download = true` enables hashing of completed single-file outputs.
`hash_algorithm` accepts `md5`, `sha1`, `sha256` (default), or `sha512`.
Directory trees are not hashed; existing checksum-derived hashes are reused.

## Maintenance

```sh
nix-shell
just update fluxdown-server
just contract fluxdown-server
just check fluxdown-server
```

Configuration comes from upstream `native/protocol/src/daemon_config.rs`; regenerate
`settings-schema.json` through the updater, not by hand. `installCheckPhase`
verifies live RPC configuration against the built server binary.
