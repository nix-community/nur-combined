# sing-box for Linux (SFL)

[Upstream](https://github.com/SagerNet/sing-box-for-desktop) Linux desktop client
and daemon from [sing-box releases](https://github.com/SagerNet/sing-box/releases)
for `x86_64-linux` and `aarch64-linux`. Exposes `sfl` (the Electron client) and
`sing-box-daemon` without colliding with nixpkgs' CLI `sing-box` binary, and
replaces the 3D Linux tray icons with white monochrome icons derived from the
bundled template assets. Licensed under GPL-3.0-or-later.

## Usage

```sh
nix build -f . sfl
```

```nix
{
  imports = [ ./modules/sfl.nix ];
  services.sfl.enable = true;
}
```

Enabling `services.sfl` installs the desktop client, registers the Polkit actions
(`io.nekohasekai.sfl.take-over-service` and `io.nekohasekai.sfl.set-insecure-mode`),
and starts `sing-box-daemon.service` on `/run/sing-box.socket` with state in
`/var/lib/sing-box-daemon` (mode `0700`). Keep profile credentials in user-managed
profiles or runtime files outside the Nix store.

`services.sfl.insecureMode = true;` disables the upstream profile security
restrictions before each daemon start, using its supported CLI. This permits
unrestricted file access and command execution as root; use only trusted profiles.
Set `false` to restore restrictions. The default `null` leaves the saved upstream
setting unmanaged; removing the option does not reset a previously enabled mode.
Polkit authentication and daemon ownership checks remain enabled.

## Maintenance and tests

```sh
nix-shell --run 'just update sfl'
nix-shell --run 'just check sfl'
```

The update script selects the latest GitHub release (including alpha/beta
prereleases) from `SagerNet/sing-box`, prefetches both `x86_64-linux` (`x64`)
and `aarch64-linux` (`aarch64`) `SFL-<version>-<arch>.pkg.tar.zst` archives, and
verifies their SHA-256 digests against the GitHub release asset metadata. Review
upstream `electron-builder.yml`, `build/sing-box-daemon.service`,
`build/io.nekohasekai.sfl.policy`, and `experimental/boxdd` when updating.

Checks verify NixOS module evaluation, binary linking, desktop/metainfo/systemd/polkit
file installation, `sing-box-daemon version`, and isolated `sing-box-daemon`
gRPC/worker readiness over a temporary Unix socket. Only the current platform is
build-tested; GUI rendering and privileged TUN/Polkit operations are not run.
