/*
  SPDX-License-Identifier: ISC AND MIT

  This file is licensed under the ISC License AND the MIT License.
  It contains code derived from https://github.com/daeuniverse/flake.nix

  --- ISC License ---
  Copyright (c) 2023, daeuniverse

  Permission to use, copy, modify, and/or distribute this software for any
  purpose with or without fee is hereby granted, provided that the above
  copyright notice and this permission notice appear in all copies.

  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

  --- MIT License ---
  Copyright (c) 2026 Nixpkgs/NixOS contributors

  Licensed under the MIT License (the same license as the rest of Nixpkgs).
  The full text of the MIT License can be found in the LICENSE file at the
  root of this repository.
*/

{
  config,
  pkgs,
  lib,
  utils,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkOption
    literalExpression
    types
    mkPackageOption
    ;

  cfg = config.services.honk-core;

  inherit (cfg) assets;
  genAssetsDrv =
    paths:
    pkgs.symlinkJoin {
      name = "honk-assets";
      inherit paths;
    };

  configPath = if cfg.configFile != null then cfg.configFile else "/etc/honk/config.dae";

  TxChecksumIpGenericWorkaround = pkgs.writeShellScript "disable-tx-checksum-ip-generic" ''
    iface=$(${lib.getExe' pkgs.iproute2 "ip"}route | ${lib.getExe' pkgs.gawk "awk"} '/default/ {print $5}')
    ${lib.getExe pkgs.ethtool} -K "$iface" tx-checksum-ip-generic off
  '';
in
{
  options.services.honk-core = {
    enable = mkEnableOption "honk, an eBPF-based transparent proxy with a Clash API";

    package = mkPackageOption pkgs "honk-core" { };

    config = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        WARNING: This option will expose your config unencrypted world-readable in the nix store.
        Config text for honk. Mutually exclusive with {option}`configFile`; the
        store path is read-only, so source administration through the native API
        needs {option}`configFile`.

        See <https://github.com/Glassyiris/honk/blob/main/config.dae>.
      '';
    };

    configFile = mkOption {
      type =
        let
          inherit (types) nullOr addCheck str;
          isAbsolutePathString = x: lib.substring 0 1 x == "/";
          isNotInStore = x: !lib.hasPrefix builtins.storeDir x;
          combineTopic = x: isAbsolutePathString x && isNotInStore x;
        in
        (nullOr (addCheck str combineTopic))
        // {
          description = "${types.str.description} (with check: should be absolute path **string** which not a store path)";
        };
      default = null;
      example = "/etc/honk/config.dae";
      description = ''
        The absolute path string of honk config file which is not in the nix
        store. Falls back to {option}`config` being written to
        {file}`/etc/honk/config.dae` if this is not set. The file must live
        outside the store so reloads and native-API source writes can update
        it.
      '';
    };

    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/honk";
      description = ''
        honk state directory, the upstream runtime root. Must match
        `global.data_dir` if that is changed in the config.
      '';
    };

    assets = mkOption {
      type = with types; listOf path;
      default = with pkgs; [
        v2ray-geoip
        v2ray-domain-list-community
      ];
      defaultText = literalExpression "with pkgs; [ v2ray-geoip v2ray-domain-list-community ]";
      description = ''
        Assets required to run honk (geosite/geoip databases used by routing
        rules).
      '';
    };

    assetsPath = mkOption {
      type = types.str;
      default = "${genAssetsDrv assets}/share/v2ray";
      defaultText = literalExpression ''
        "''${pkgs.symlinkJoin {
          name = "honk-assets";
          paths = config.services.honk-core.assets;
        }}/share/v2ray"
      '';
      description = ''
        The path which contains the geolocation database.
        This option will override `assets`.
      '';
    };

    openFirewall = {
      enable = mkEnableOption "opening `port` in the firewall";
      port = mkOption {
        type = types.port;
        default = 12345;
        description = ''
          Port to be opened. Consist with `tproxy_port` in honk configuration.
        '';
      };
    };

    disableTxChecksumIpGeneric = mkEnableOption "" // {
      description = "See <https://github.com/daeuniverse/dae/issues/43>.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = (cfg.config == null) != (cfg.configFile == null);
        message = ''
          Exactly one of `services.honk-core.config` and `services.honk-core.configFile`
          must be set.
        '';
      }
    ];

    # The ActivityPub `services.honk` module removed from nixpkgs in 26.11
    # used the same /var/lib/honk root (StateDirectory = "honk"): its database
    # lives at /var/lib/honk/honk.db, honk-core's at /var/lib/honk/state. The
    # files do not collide, but the directory is shared with any leftovers.
    warnings = lib.optional (lib.versionOlder config.system.stateVersion "26.11") ''
      services.honk-core: /var/lib/honk was the state directory of
      `services.honk` (ActivityPub), removed in nixpkgs 26.11. Its old data
      (honk.db, views/, backup/) stays untouched; honk-core keeps its state
      in /var/lib/honk/state.
    '';

    environment.systemPackages = [ cfg.package ];

    environment.etc = lib.mkIf (cfg.configFile == null) {
      "honk/config.dae" = {
        mode = "0400";
        source = pkgs.writeText "config.dae" cfg.config;
      };
    };

    networking.firewall = lib.mkIf cfg.openFirewall.enable {
      allowedTCPPorts = [ cfg.openFirewall.port ];
      allowedUDPPorts = [ cfg.openFirewall.port ];
    };

    # /run/netns holds honk's compat bind-mount of the daens namespace; the
    # state directory holds the SQLite state db and runtime assets.
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 root root - -"
      "d /run/netns 0755 root root - -"
    ];

    # Consume the unit shipped in the honk repository (install/honk.service,
    # installed into the package); only the Nix-specific Exec* and runtime
    # paths are overlaid as a drop-in.
    systemd.packages = [ cfg.package ];

    systemd.services.honk = {
      wantedBy = [ "multi-user.target" ];
      reloadTriggers = [ cfg.config ];
      serviceConfig = {
        # A drop-in replaces Exec* only after an empty assignment clears the
        # unit's /usr/bin entries.
        ExecStart = [
          ""
          (utils.escapeSystemdExecArgs [
            (lib.getExe cfg.package)
            "--disable-timestamp"
            "--data-dir"
            cfg.dataDir
            "-c"
            configPath
          ])
        ];
        ExecReload = [
          ""
          (utils.escapeSystemdExecArgs [
            (lib.getExe cfg.package)
            "reload"
          ])
        ];
        ExecStartPre = lib.optional cfg.disableTxChecksumIpGeneric (
          utils.escapeSystemdExecArgs [ TxChecksumIpGenericWorkaround ]
        );
        WorkingDirectory = cfg.dataDir;
        Environment = "DAE_LOCATION_ASSET=${cfg.assetsPath}";
      };
    };
  };

  meta.maintainers = with lib.maintainers; [ ccicnce113424 ];
}
