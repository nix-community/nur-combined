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

  configBaseName = "honk";
  configDir = "/etc/${configBaseName}";
  configFragmentDir = "${configDir}/config.d";
  # The entry config honk is started with (`-c`). systemd-tmpfiles seeds it
  # once; afterwards it belongs to whoever edits it by hand or through the web
  # UI.
  configPath = "${configDir}/config.dae";

  # honk resolves symlinks when it loads an `include` and refuses the whole
  # configuration unless every included file ends up inside the entry config's
  # own directory. A tree of store symlinks therefore only works while nothing
  # ever writes to it, so /etc/honk holds real files instead: an
  # `environment.etc` entry whose mode is not "symlink" is copied on every
  # activation. They are copies of Nix-owned files, hence read-only, like the
  # store paths they come from.
  # The startup-only settings and the native API live in one fragment; the
  # entry config imports it.
  generatedConfigText = ''
    global {
        data_dir: '${cfg.dataDir}'
        tproxy_port: ${toString cfg.tproxyPort}
        wan_interface: ${cfg.wanInterface}
        ${lib.optionalString (cfg.lanInterface != "") "    lan_interface: ${cfg.lanInterface}"}
        nfqueue_enable: ${lib.boolToString cfg.nfqueue}
    }
  ''
  + lib.optionalString cfg.doona.enable ''
    experimental {
        native_api {
            enabled: true
            password_auth: true
            config_write: true
            listen: '${cfg.doona.listenAddress}:${toString cfg.doona.port}'
            ui: '${cfg.doona.package}'
        }
    }
  '';

  generatedConfig = pkgs.writeText "10-nix.dae" generatedConfigText;

  generatedFragments = {
    "10-nix.dae" = {
      source = generatedConfig;
    };
  };

  allFragments = generatedFragments // cfg.configFiles;

  declaredFragments = lib.mapAttrs' (
    name: fragment:
    lib.nameValuePair "${configBaseName}/config.d/${name}" (
      { mode = "0440"; } // lib.filterAttrs (_: value: value != null) fragment
    )
  ) allFragments;

  # The seed of the entry config: the blocks the web UI edits and the import
  # that loads config.d/.
  entrySeed = pkgs.writeText "config.dae" ''
    # honk's entry config: the web UI writes its global and routing rules here.
    #
    # Do not change the import: it loads the Nix-managed files in config.d/.
    include {
        'config.d/*.dae'
    }
    global { }
    routing { }
  '';

  TxChecksumIpGenericWorkaround = pkgs.writeShellScript "disable-tx-checksum-ip-generic" ''
    iface=$(${lib.getExe' pkgs.iproute2 "ip"} route | ${lib.getExe' pkgs.gawk "awk"} '/default/ {print $5}')
    ${lib.getExe pkgs.ethtool} -K "$iface" tx-checksum-ip-generic off
  '';

  # honk-tool resolves geosite.dat/geoip.dat through DAE_LOCATION_ASSET. Wrap
  # the package's tool so it points at the same asset set the service uses;
  # the package itself wraps in iproute2 for `diagnose`.
  honkTool =
    pkgs.runCommand "honk-tool-wrapped"
      {
        nativeBuildInputs = [ pkgs.makeWrapper ];
      }
      ''
        makeWrapper ${lib.getExe' cfg.package "honk-tool"} $out/bin/honk-tool \
          --set-default DAE_LOCATION_ASSET ${lib.escapeShellArg (toString cfg.assetsPath)}
      '';
in
{
  options.services.honk-core = {
    enable = mkEnableOption "honk, an eBPF-based transparent proxy with a Clash API";

    package = mkPackageOption pkgs "honk-core" { };

    nfqueue = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether to enable honk's NFQUEUE staging (`global.nfqueue_enable`) and
        load the `nfnetlink_queue` kernel module for it. The key is written
        explicitly so the configuration never disagrees with the runtime —
        a mismatch blocks configuration writes from the web UI. See
        <https://github.com/Glassyiris/honk/blob/main/doc/en/reference/global.md>.
      '';
    };

    doona = {
      enable =
        mkEnableOption "the doona web UI and honk's native API (password login, configuration writes)"
        // {
          default = true;
        };
      package = mkPackageOption pkgs "doona-web" {
        example = [ "doona-lite" ];
      };
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
      type = types.attrsOf (
        types.submodule {
          options = {
            source = mkOption {
              type = types.nullOr types.path;
              default = null;
              description = "Path of the fragment, used instead of {option}`text`.";
            };
            text = mkOption {
              type = types.nullOr types.lines;
              default = null;
              description = "Contents of the fragment, used when no {option}`source` is set.";
            };
          };
        }
      );
      default = { };
      example = literalExpression ''
        {
          "30-routing.dae".source = ./honk/routing.dae;
          "40-check.dae".text = "global { check_interval: 10s }";
        }
      '';
      description = ''
        Extra honk configuration fragments, keyed by the file name they get in
        {file}`/etc/honk/config.d/`. The entry config imports every `*.dae` file
        of that directory in name order, so a key another fragment also sets
        wins if it sorts later. Fragments are copied on every activation:
        runtime edits belong in {file}`/etc/honk/config.dae`, and a file dropped
        into that directory by hand is imported too, but unmanaged.
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
        assertion =
          lib.all (name: lib.hasSuffix ".dae" name) (builtins.attrNames cfg.configFiles)
          && lib.all (name: !(builtins.hasAttr name generatedFragments)) (builtins.attrNames cfg.configFiles);
        message = ''
          services.honk-core.configFiles: names must end in '.dae' and must not
          collide with the generated fragment ('10-nix.dae').
        '';
      }
      {
        assertion = lib.all (
          name:
          let
            file = cfg.configFiles.${name};
          in
          file.source == null || file.text == null
        ) (builtins.attrNames cfg.configFiles);
        message = ''
          services.honk-core.configFiles: set either 'source' or 'text' for each
          fragment, not both.
        '';
      }
    ];

    # NFQUEUE staging needs the netlink family (see the `nfqueue` option).
    boot.kernelModules = lib.optional cfg.nfqueue "nfnetlink_queue";

    networking.firewall = {
      allowedTCPPorts =
        lib.optional cfg.openFirewall cfg.tproxyPort
        ++ lib.optional (cfg.doona.enable && cfg.doona.openFirewall) cfg.doona.port;
      allowedUDPPorts = lib.optional cfg.openFirewall cfg.tproxyPort;
    };

    environment.etc = declaredFragments;

    environment.systemPackages = lib.optional cfg.package.withTool honkTool;

    # /run/netns holds honk's compat bind-mount of the daens namespace; the
    # state directory holds the SQLite state db and runtime assets.
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 root root - -"
      "d /run/netns 0755 root root - -"
      # The configuration tree belongs to root: honk and its web UI run as
      # root, and it is the directory write bit, not the mode of the files
      # inside, that decides whether somebody can replace them.
      "d ${configDir} 0700 root root - -"
      "d ${configFragmentDir} 0700 root root - -"
      # Created once and never overwritten: the entry config belongs to
      # whoever edits it by hand or through the web UI.
      "C ${configPath} 0600 root root - ${entrySeed}"
    ];

    # The upstream unit is installed into the package as honk-core.service;
    # the Nix-specific Exec* and runtime paths are overlaid as a drop-in.
    systemd.packages = [ cfg.package ];

    systemd.services.honk-core = {
      wantedBy = [ "multi-user.target" ];
      # The generated fragment carries the startup-only settings, so changing
      # it restarts the unit. Everything else — the entry config and the user
      # fragments — is picked up by honk's reload.
      restartTriggers = [ generatedConfig ];
      reloadTriggers = lib.mapAttrsToList (
        name: _: config.environment.etc."${configBaseName}/config.d/${name}".source
      ) cfg.configFiles;
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
