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

  doonaConfig = ''
    experimental {
        native_api {
            enabled: true
            password_auth: true
            config_write: true
            listen: '${cfg.doona.listenAddress}:${toString cfg.doona.port}'
            ui: '${cfg.doona.package}/share/doona-web'
        }
    }
  '';

  configBaseName = "honk";
  configDir = "/etc/${configBaseName}";
  configFragmentDir = "${configDir}/config.d";

  # honk resolves symlinks when it loads an `include` and refuses the whole
  # configuration unless every included file ends up inside the entry config's
  # own directory. A tree of store symlinks therefore only works while nothing
  # ever writes to it, so /etc/honk holds real files instead: an
  # `environment.etc` entry whose mode is not "symlink" is copied on every
  # activation. They are copies of Nix-owned files, hence read-only, like the
  # store paths they come from.
  fragmentName = file: builtins.unsafeDiscardStringContext (baseNameOf file);

  declaredFragments = lib.genAttrs' cfg.configFiles (
    file:
    lib.nameValuePair "${configBaseName}/config.d/${fragmentName file}" {
      mode = "0400";
      source = file;
    }
  );

  # The entry config is the file honk is started with (`-c`). It is copied
  # from the store on every activation, so edits made at runtime (including
  # through the web UI) are lost on the next switch; runtime changes belong
  # into the included fragments.
  entryConfig = pkgs.writeText "config.dae" (
    ''
      global {
          data_dir: '${cfg.dataDir}'
          tproxy_port: ${toString cfg.tproxyPort}
          wan_interface: ${cfg.wanInterface}
          ${lib.optionalString (cfg.lanInterface != "") "    lan_interface: ${cfg.lanInterface}"}
      }
      include {
          '${configFragmentDir}/*.dae'
      }
    ''
    + lib.optionalString cfg.doona.enable doonaConfig
  );

  TxChecksumIpGenericWorkaround = pkgs.writeShellScript "disable-tx-checksum-ip-generic" ''
    iface=$(${lib.getExe' pkgs.iproute2 "ip"} route | ${lib.getExe' pkgs.gawk "awk"} '/default/ {print $5}')
    ${lib.getExe pkgs.ethtool} -K "$iface" tx-checksum-ip-generic off
  '';
in
{
  options.services.honk-core = {
    enable = mkEnableOption "honk, an eBPF-based transparent proxy with a Clash API";

    package = mkPackageOption pkgs "honk-core" { };

    doona = {
      enable = mkEnableOption "the doona web UI and honk's native API (password login, configuration writes)";
      package = mkPackageOption pkgs "doona-web" { };
      listenAddress = mkOption {
        type = types.str;
        default = "127.0.0.1";
        example = "0.0.0.0";
        description = ''
          Address the native API and the web UI bind to. The default keeps
          them on loopback; exposing them needs a matching firewall rule (see
          {option}`services.honk-core.openFirewall`), and honk's password login
          applies either way.
        '';
      };
      port = mkOption {
        type = types.port;
        default = 9527;
        description = ''
          Port the native API and the web UI listen on
          (`experimental.native_api.listen`).
        '';
      };
      openFirewall = mkEnableOption "opening the web UI and native API port in the firewall";
    };

    configFiles = mkOption {
      type = with lib.types; listOf path;
      default = [ ];
      example = literalExpression "[ ./honk/routing.dae ]";
      description = ''
        Extra honk configuration fragments. Each file is copied to
        {file}`/etc/honk/config.d/<file name>` on every activation, so edits
        made at runtime (including through the web UI) are overwritten; the
        generated entry config includes every `*.dae` file of that directory,
        so the file name must end in `.dae`.
      '';
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/honk";
      description = ''
        honk state directory, the upstream runtime root. Set as
        `global.data_dir` in the generated entry config.
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
      type = types.path;
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

    tproxyPort = mkOption {
      type = types.port;
      default = 12345;
      description = ''
        Port honk's transparent proxy listens on for TCP and UDP traffic,
        written to `global.tproxy_port` in the generated entry config.
      '';
    };

    wanInterface = mkOption {
      type = types.commas;
      default = "auto";
      example = "eth0, eth1";
      description = ''
        Interfaces carrying this host's own traffic (`global.wan_interface`);
        `auto` follows the IPv4 default-route interface. Startup-only: honk
        refuses to change it through the API.
      '';
    };

    lanInterface = mkOption {
      type = types.commas;
      default = "";
      example = "eth1, eth2";
      description = ''
        Interfaces receiving forwarded LAN traffic (`global.lan_interface`).
        Empty by default, which leaves honk a host-only proxy. Startup-only.
      '';
    };

    openFirewall = mkEnableOption "opening the transparent proxy port in the firewall";

    disableTxChecksumIpGeneric = mkEnableOption "" // {
      description = "See <https://github.com/daeuniverse/dae/issues/43>.";
    };
  };

  config = lib.mkIf cfg.enable {
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

    assertions = [
      {
        assertion = lib.all (file: lib.hasSuffix ".dae" (fragmentName file)) cfg.configFiles;
        message = ''
          services.honk-core.configFiles: the generated entry config only
          includes files named '*.dae'.
        '';
      }
    ];

    networking.firewall = {
      allowedTCPPorts =
        lib.optional cfg.openFirewall cfg.tproxyPort
        ++ lib.optional (cfg.doona.enable && cfg.doona.openFirewall) cfg.doona.port;
      allowedUDPPorts = lib.optional cfg.openFirewall cfg.tproxyPort;
    };

    environment.etc = declaredFragments // {
      "${configBaseName}/config.dae" = {
        mode = "0400";
        source = entryConfig;
      };
    };

    # /run/netns holds honk's compat bind-mount of the daens namespace; the
    # state directory holds the SQLite state db and runtime assets.
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 root root - -"
      "d /run/netns 0755 root root - -"
      "d ${configFragmentDir} 0750 root root - -"
      # Created once and never overwritten: this fragment belongs to whoever
      # edits it by hand or through the web UI, NixOS only provides the file.
      "f ${configFragmentDir}/99-local.dae 0600 root root -"
    ];

    # Consume the unit shipped in the honk repository (install/honk.service,
    # installed into the package); only the Nix-specific Exec* and runtime
    # paths are overlaid as a drop-in.
    systemd.packages = [ cfg.package ];

    systemd.services.honk = {
      wantedBy = [ "multi-user.target" ];
      # The entry config carries the startup-only settings (data directory,
      # native API); changes to a fragment are picked up by honk's reload.
      restartTriggers = [ entryConfig ];
      reloadTriggers = cfg.configFiles;
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
            "${configDir}/config.dae"
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
