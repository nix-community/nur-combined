# MCSManager Nix Package & NixOS Module Design

## Overview

Package MCSManager (a distributed game server management panel) as Nix derivations and a NixOS module for this NUR repository. MCSManager has two processes: a web panel (user-facing UI + API) and a daemon (manages game server instances). They communicate over HTTP/WebSocket.

## Approach: Prebuilt Release Tarballs

MCSManager publishes prebuilt release tarballs on GitHub containing webpack/vite-compiled JS bundles with `node_modules` already installed. We fetch these with `fetchurl` and use `stdenv.mkDerivation` to install the files. The daemon tarball also includes native binaries (pty, zip tools, 7z) for all platforms — we only install the Linux ones.

The daemon tarball contains 2 native `.node` modules (cpu-features, ssh2 crypto) that need `autoPatchelfHook` to work on NixOS.

## Package Derivations

Three derivations under `pkgs/mcsmanager/`:

### mcsmanager-daemon (daemon.nix)

- Fetches `mcsmanager_linux_daemon_only_release.tar.gz` from GitHub releases
- Uses `stdenv.mkDerivation` + `autoPatchelfHook` (native .node modules need patching)
- Installs: `app.js`, `app.js.map`, `node_modules/`, `lib/` (platform-filtered native binaries)

### mcsmanager-web (web.nix)

- Fetches `mcsmanager_linux_web_only_release.tar.gz` from GitHub releases
- Uses `stdenv.mkDerivation` (no native modules)
- Installs: `app.js`, `app.js.map`, `node_modules/`, `public/` (frontend assets)

### mcsmanager (package.nix)

- Entry point for auto-discovery by `callDirPackageWithRecursive`
- Exposes `{ mcsmanager-daemon, mcsmanager-web }` with `recurseForDerivations = true`

## NixOS Module

Located at `modules/nixos/mcsmanager/default.nix`.

### Options

**`services.mcsmanager.daemon`:**

- `enable` - boolean
- `port` - default 24444
- `dataDir` - default `/var/lib/mcsmanager/daemon`
- `openFirewall` - boolean, default false

**`services.mcsmanager.panel`:**

- `enable` - boolean
- `port` - default 23333
- `dataDir` - default `/var/lib/mcsmanager/web`
- `openFirewall` - boolean, default false

### Systemd Services

Both `mcsmanager-daemon.service` and `mcsmanager-panel.service`:

- Run as dedicated `mcsmanager` user/group (shared)
- `WorkingDirectory` = respective `dataDir` (so `process.cwd()` resolves state correctly)
- `ExecStartPre` creates symlinks from dataDir to Nix store package contents
- `ExecStart` = `node --max-old-space-size=8192 --enable-source-maps app.js`
- Basic systemd hardening (ProtectSystem, ProtectHome, etc.)
- `StateDirectory` for automatic directory creation

### Firewall

When `openFirewall = true`, opens the respective port via `networking.firewall.allowedTCPPorts`.

## Runtime Directory Layout

Both processes use `process.cwd()` to find files. The working directory (dataDir) contains symlinks to immutable Nix store paths plus mutable state:

**Daemon** (`/var/lib/mcsmanager/daemon/`):

```
app.js           -> /nix/store/.../app.js
app.js.map       -> /nix/store/.../app.js.map
node_modules     -> /nix/store/.../node_modules
lib/             -> /nix/store/.../lib  (platform-filtered native binaries)
data/            (mutable)
logs/            (mutable)
```

**Panel** (`/var/lib/mcsmanager/web/`):

```
app.js           -> /nix/store/.../app.js
app.js.map       -> /nix/store/.../app.js.map
node_modules     -> /nix/store/.../node_modules
public           -> /nix/store/.../public
data/            (mutable)
logs/            (mutable)
```

Symlinks are recreated on each service start, so package upgrades point to new store paths automatically. Mutable directories (`data/`, `logs/`) are preserved across upgrades.

## File Layout in NUR Repo

```
pkgs/mcsmanager/
  package.nix       # Auto-discovered entry point
  daemon.nix        # Daemon derivation
  web.nix           # Web/panel derivation

modules/nixos/mcsmanager/
  default.nix       # NixOS module
```

## Version

Initial target: v10.12.2 (latest release as of 2026-02-13).

- Panel version: 10.12.2
- Daemon version: 4.12.1
