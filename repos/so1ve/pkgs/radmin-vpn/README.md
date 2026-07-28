# Radmin VPN

`x86_64-linux` package for the upstream AppImage. The AppImage includes Wine.

## Install

```nix
environment.systemPackages = [
  pkgs.nur.repos.so1ve.radmin-vpn
];
```

Launch it from the desktop menu or run:

```bash
radmin-vpn
```

On first launch it downloads the proprietary Radmin VPN 2.0.4899.9 installer
to `$XDG_DATA_HOME/radmin-vpn-linux` and creates a Wine prefix there. It uses
`sudo` to create `radminvpn0` and configure the interface's addresses and
routes.

> [!NOTE]
> This package includes a security hardening patch for the upstream privileged
> network-command relay: it accepts only the expected `ip` operations and
> executes them directly instead of passing arbitrary text to `sudo sh -c`.

## Options

| CLI option | Nix override |
| --- | --- |
| `--no-ui` | None |
| `--no-broadcast-routes` | None |
| `--fix-chat` | `withChatFix = true` (adds Python) |
| `--filter-ui` | `withFilterUi = true` (adds GTK 4, GLib and Pango) |

```nix
(pkgs.nur.repos.so1ve.radmin-vpn.override {
  withChatFix = true;
  withFilterUi = true;
})
```
