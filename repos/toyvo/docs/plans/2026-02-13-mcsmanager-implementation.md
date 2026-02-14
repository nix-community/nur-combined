# MCSManager Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Package MCSManager as Nix derivations and a NixOS module so consumers can enable the daemon and/or panel as NixOS services.

**Architecture:** Fetch prebuilt release tarballs from GitHub, install with stdenv.mkDerivation (autoPatchelfHook for daemon's native modules). NixOS module creates systemd services that symlink Nix store contents into a mutable working directory.

**Tech Stack:** Nix, NixOS modules, stdenv.mkDerivation, fetchurl, autoPatchelfHook, systemd

______________________________________________________________________

### Task 1: Create mcsmanager-web derivation

**Files:**

- Create: `pkgs/mcsmanager/web.nix`

**Step 1: Write web.nix**

```nix
{
  lib,
  stdenv,
  fetchurl,
}:
stdenv.mkDerivation rec {
  pname = "mcsmanager-web";
  version = "10.12.2";

  src = fetchurl {
    url = "https://github.com/MCSManager/MCSManager/releases/download/v${version}/mcsmanager_linux_web_only_release.tar.gz";
    hash = "sha256-SMz4pj4VP4nZJYZhNBSOJxO6dtJRVSBx9UIbAnA+3T8=";
  };

  sourceRoot = "mcsmanager/web";

  dontBuild = true;
  dontConfigure = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/mcsmanager/web
    cp -r app.js app.js.map node_modules public package.json $out/lib/mcsmanager/web/
    runHook postInstall
  '';

  meta = with lib; {
    description = "MCSManager web panel - distributed game server management interface";
    homepage = "https://mcsmanager.com/";
    license = licenses.asl20;
    platforms = platforms.linux;
    maintainers = with maintainers; [ toyvo ];
  };
}
```

**Step 2: Verify it builds**

Run: `nix build ".#mcsmanager-web"`
Expected: Successful build, output in `/nix/store/...-mcsmanager-web-10.12.2/lib/mcsmanager/web/`

**Step 3: Verify output contents**

Run: `ls $(nix build ".#mcsmanager-web" --print-out-paths)/lib/mcsmanager/web/`
Expected: `app.js  app.js.map  node_modules  package.json  public`

**Step 4: Commit**

```bash
git add pkgs/mcsmanager/web.nix
git commit -m "feat: add mcsmanager-web derivation"
```

______________________________________________________________________

### Task 2: Create mcsmanager-daemon derivation

**Files:**

- Create: `pkgs/mcsmanager/daemon.nix`

The daemon tarball contains native `.node` modules (cpu-features, ssh2) and native binaries in `lib/` (pty, file_zip, 7z). These are prebuilt ELF binaries that need `autoPatchelfHook` to work on NixOS. The tarball includes binaries for all platforms — we only keep the Linux ones for the current architecture.

**Step 1: Write daemon.nix**

```nix
{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  gcc-unwrapped,
}:
stdenv.mkDerivation rec {
  pname = "mcsmanager-daemon";
  version = "4.12.1";

  src = fetchurl {
    url = "https://github.com/MCSManager/MCSManager/releases/download/v10.12.2/mcsmanager_linux_daemon_only_release.tar.gz";
    hash = "sha256-oDZ9AJpzLuSoCClvgYceH9KMdEZoitD/mqR2pbUl7Uw=";
  };

  sourceRoot = "mcsmanager/daemon";

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ gcc-unwrapped.lib ];

  dontBuild = true;
  dontConfigure = true;

  installPhase =
    let
      arch = if stdenv.hostPlatform.isx86_64 then "x64" else "arm64";
    in
    ''
      runHook preInstall
      mkdir -p $out/lib/mcsmanager/daemon/lib

      cp app.js app.js.map package.json $out/lib/mcsmanager/daemon/
      cp -r node_modules $out/lib/mcsmanager/daemon/

      # Install only platform-appropriate native binaries
      for bin in pty_linux_${arch} file_zip_linux_${arch} 7z_linux_${arch}; do
        if [ -f "lib/$bin" ]; then
          install -m755 "lib/$bin" "$out/lib/mcsmanager/daemon/lib/$bin"
        fi
      done

      # License files for 7z
      cp lib/7z-*.txt $out/lib/mcsmanager/daemon/lib/ 2>/dev/null || true

      runHook postInstall
    '';

  meta = with lib; {
    description = "MCSManager daemon - manages game server instances";
    homepage = "https://mcsmanager.com/";
    license = licenses.asl20;
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    maintainers = with maintainers; [ toyvo ];
  };
}
```

**Step 2: Verify it builds**

Run: `nix build ".#mcsmanager-daemon"`
Expected: Successful build. autoPatchelfHook patches the .node files and lib/ binaries.

**Step 3: Verify output contents**

Run: `ls $(nix build ".#mcsmanager-daemon" --print-out-paths)/lib/mcsmanager/daemon/lib/`
Expected: Platform-appropriate binaries only (e.g., `pty_linux_x64  file_zip_linux_x64  7z_linux_x64`)

**Step 4: Commit**

```bash
git add pkgs/mcsmanager/daemon.nix
git commit -m "feat: add mcsmanager-daemon derivation"
```

______________________________________________________________________

### Task 3: Create package.nix entry point

**Files:**

- Create: `pkgs/mcsmanager/package.nix`

This is the auto-discovered entry point. It exposes both sub-packages with `recurseForDerivations` so they appear in `nix flake show` and CI checks.

**Step 1: Write package.nix**

```nix
{ callPackage, lib, ... }:
lib.recurseIntoAttrs {
  mcsmanager-daemon = callPackage ./daemon.nix { };
  mcsmanager-web = callPackage ./web.nix { };
}
```

**Step 2: Verify both packages appear in flake**

Run: `nix flake show 2>&1 | grep mcsmanager`
Expected: Both `mcsmanager-daemon` and `mcsmanager-web` listed under packages and checks.

**Step 3: Build both**

Run: `nix build ".#mcsmanager-daemon" && nix build ".#mcsmanager-web"`
Expected: Both build successfully.

**Step 4: Commit**

```bash
git add pkgs/mcsmanager/package.nix
git commit -m "feat: add mcsmanager package entry point"
```

______________________________________________________________________

### Task 4: Create NixOS module

**Files:**

- Create: `modules/nixos/mcsmanager/default.nix`

The module defines two independent services. Each creates a systemd service with an `ExecStartPre` script that symlinks Nix store package contents into the mutable working directory.

**Step 1: Write modules/nixos/mcsmanager/default.nix**

```nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.mcsmanager;
in
{
  options.services.mcsmanager = {
    daemon = {
      enable = lib.mkEnableOption "MCSManager daemon (game server instance manager)";
      package = lib.mkPackageOption pkgs "mcsmanager-daemon" {
        default = [ "toyvo" "mcsmanager" "mcsmanager-daemon" ];
      };
      port = lib.mkOption {
        type = lib.types.port;
        default = 24444;
        description = "Port for the MCSManager daemon to listen on.";
      };
      dataDir = lib.mkOption {
        type = lib.types.path;
        default = "/var/lib/mcsmanager/daemon";
        description = "Directory for MCSManager daemon state data.";
      };
      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to open the daemon port in the firewall.";
      };
    };

    panel = {
      enable = lib.mkEnableOption "MCSManager web panel (management interface)";
      package = lib.mkPackageOption pkgs "mcsmanager-web" {
        default = [ "toyvo" "mcsmanager" "mcsmanager-web" ];
      };
      port = lib.mkOption {
        type = lib.types.port;
        default = 23333;
        description = "Port for the MCSManager web panel to listen on.";
      };
      dataDir = lib.mkOption {
        type = lib.types.path;
        default = "/var/lib/mcsmanager/web";
        description = "Directory for MCSManager web panel state data.";
      };
      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to open the panel port in the firewall.";
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.daemon.enable {
      systemd.services.mcsmanager-daemon = {
        description = "MCSManager Daemon";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];

        preStart = ''
          # Symlink immutable files from Nix store into working directory
          ln -sfn ${cfg.daemon.package}/lib/mcsmanager/daemon/app.js app.js
          ln -sfn ${cfg.daemon.package}/lib/mcsmanager/daemon/app.js.map app.js.map
          ln -sfn ${cfg.daemon.package}/lib/mcsmanager/daemon/node_modules node_modules
          ln -sfn ${cfg.daemon.package}/lib/mcsmanager/daemon/package.json package.json
          ln -sfn ${cfg.daemon.package}/lib/mcsmanager/daemon/lib lib

          # Ensure mutable directories exist
          mkdir -p data logs
        '';

        serviceConfig = {
          Type = "simple";
          User = "mcsmanager";
          Group = "mcsmanager";
          WorkingDirectory = cfg.daemon.dataDir;
          ExecStart = "${pkgs.nodejs}/bin/node --max-old-space-size=8192 --enable-source-maps app.js";
          Restart = "on-failure";
          RestartSec = "5s";

          # Hardening
          ProtectSystem = "strict";
          ProtectHome = true;
          ReadWritePaths = [ cfg.daemon.dataDir ];
          PrivateTmp = true;
          NoNewPrivileges = true;
        };
      };

      systemd.tmpfiles.rules = [
        "d ${cfg.daemon.dataDir} 0750 mcsmanager mcsmanager -"
      ];

      networking.firewall.allowedTCPPorts = lib.mkIf cfg.daemon.openFirewall [ cfg.daemon.port ];
    })

    (lib.mkIf cfg.panel.enable {
      systemd.services.mcsmanager-panel = {
        description = "MCSManager Web Panel";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];

        preStart = ''
          # Symlink immutable files from Nix store into working directory
          ln -sfn ${cfg.panel.package}/lib/mcsmanager/web/app.js app.js
          ln -sfn ${cfg.panel.package}/lib/mcsmanager/web/app.js.map app.js.map
          ln -sfn ${cfg.panel.package}/lib/mcsmanager/web/node_modules node_modules
          ln -sfn ${cfg.panel.package}/lib/mcsmanager/web/package.json package.json
          ln -sfn ${cfg.panel.package}/lib/mcsmanager/web/public public

          # Ensure mutable directories exist
          mkdir -p data logs
        '';

        serviceConfig = {
          Type = "simple";
          User = "mcsmanager";
          Group = "mcsmanager";
          WorkingDirectory = cfg.panel.dataDir;
          ExecStart = "${pkgs.nodejs}/bin/node --max-old-space-size=8192 --enable-source-maps app.js";
          Restart = "on-failure";
          RestartSec = "5s";

          # Hardening
          ProtectSystem = "strict";
          ProtectHome = true;
          ReadWritePaths = [ cfg.panel.dataDir ];
          PrivateTmp = true;
          NoNewPrivileges = true;
        };
      };

      systemd.tmpfiles.rules = [
        "d ${cfg.panel.dataDir} 0750 mcsmanager mcsmanager -"
      ];

      networking.firewall.allowedTCPPorts = lib.mkIf cfg.panel.openFirewall [ cfg.panel.port ];
    })

    (lib.mkIf (cfg.daemon.enable || cfg.panel.enable) {
      users.users.mcsmanager = {
        isSystemUser = true;
        group = "mcsmanager";
        home = "/var/lib/mcsmanager";
      };
      users.groups.mcsmanager = { };
    })
  ];
}
```

Note: The `package` option defaults will need to match how the overlay exposes these packages. If the packages are accessed as `pkgs.toyvo.mcsmanager.mcsmanager-daemon` via the overlay, the default path should reflect that. This may need adjustment during testing — the default can also just be the derivation directly if the overlay path is tricky. An alternative is to remove the `mkPackageOption` and use a plain option with `default = pkgs.toyvo.mcsmanager.mcsmanager-daemon` or import the derivation directly.

**Step 2: Verify the module is discovered by the flake**

Run: `nix flake show 2>&1 | grep -A2 modules`
Expected: `modules.nixos.mcsmanager` appears in output.

**Step 3: Commit**

```bash
git add modules/nixos/mcsmanager/default.nix
git commit -m "feat: add MCSManager NixOS module"
```

______________________________________________________________________

### Task 5: Validate and iterate

**Step 1: Run nix flake show**

Run: `nix flake show`
Expected: Clean output showing packages (mcsmanager-daemon, mcsmanager-web) and modules (mcsmanager).

**Step 2: Build both packages**

Run: `nix build ".#mcsmanager-daemon" && nix build ".#mcsmanager-web"`
Expected: Both succeed.

**Step 3: Verify daemon native binaries are patched**

Run: `file $(nix build ".#mcsmanager-daemon" --print-out-paths)/lib/mcsmanager/daemon/lib/pty_linux_x64`
Expected: ELF binary with proper interpreter (not the upstream hardcoded one).

**Step 4: Run nix fmt**

Run: `nix fmt`
Expected: All new files are formatted correctly.

**Step 5: Run NUR validation**

Run: `nix-env -f . -qa \* --meta --xml --allowed-uris https://static.rust-lang.org --option allow-import-from-derivation true --drv-path --show-trace -I $PWD`
Expected: mcsmanager packages appear in the output without errors.

**Step 6: Commit any formatting fixes**

```bash
git add -A
git commit -m "chore: format mcsmanager package files"
```
