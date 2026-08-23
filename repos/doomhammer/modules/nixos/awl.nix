{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.awl;

  inherit (lib)
    escapeShellArg
    literalExpression
    mapAttrsToList
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    optional
    optionalString
    types
    ;

  jsonFormat = pkgs.formats.json { };

  hasInlineSettings = cfg.settings != { };
  generatedConfig = jsonFormat.generate "config_awl.json" cfg.settings;
  configSource =
    if cfg.configFile != null then
      cfg.configFile
    else if hasInlineSettings then
      generatedConfig
    else
      null;
  hasConfigSource = configSource != null;

  dataDirArg = escapeShellArg cfg.dataDir;
  configTarget = "${cfg.dataDir}/config_awl.json";
  configTargetArg = escapeShellArg configTarget;
  configTmpArg = escapeShellArg "${cfg.dataDir}/.config_awl.json.tmp";
  configSourceArg = escapeShellArg (toString configSource);

  environment = [
    "AWL_DATA_DIR=${cfg.dataDir}"
  ]
  ++ mapAttrsToList (name: value: "${name}=${toString value}") cfg.environment;

  capabilitiesConfig = mkIf (cfg.user != "root" || cfg.hardening.enable) {
    AmbientCapabilities = cfg.capabilities;
    CapabilityBoundingSet = cfg.capabilities;
  };

  hardeningConfig = mkIf cfg.hardening.enable {
    NoNewPrivileges = true;
    PrivateTmp = true;
    ProtectHome = true;
    ProtectSystem = "strict";
    ReadWritePaths = [ cfg.dataDir ] ++ cfg.hardening.readWritePaths;
    RestrictAddressFamilies = [
      "AF_UNIX"
      "AF_INET"
      "AF_INET6"
      "AF_NETLINK"
    ];
    LockPersonality = true;
    RestrictRealtime = true;
    SystemCallArchitectures = "native";
  };
in
{
  options.services.awl = {
    enable = mkEnableOption "headless Anywherelan mesh VPN daemon";

    package = mkOption {
      type = types.package;
      default = pkgs.callPackage ../../../pkgs/awl-bin { };
      defaultText = literalExpression "pkgs.callPackage ../../../pkgs/awl-bin { }";
      example = literalExpression "inputs.nixos-anywherelan.packages.${pkgs.system}.awl";
      description = ''
        AWL package to run. Use this if you overlay a newer package, switch
        from the binary package to a future source-built package, or pin an
        internal build.
      '';
    };

    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/anywherelan";
      description = ''
        Runtime state directory used as AWL_DATA_DIR. AWL stores config_awl.json,
        identity material, peer state, and peerstore data here.
      '';
    };

    user = mkOption {
      type = types.str;
      default = "root";
      description = ''
        User that runs AWL. The default is root because AWL creates and manages
        a TUN interface. Non-root operation requires suitable capabilities and
        should be tested on the target host.
      '';
    };

    group = mkOption {
      type = types.str;
      default = "root";
      description = "Group that runs AWL.";
    };

    createUser = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Create services.awl.user and services.awl.group as system account/group.
        Usually false when running as root.
      '';
    };

    capabilities = mkOption {
      type = types.listOf types.str;
      default = [
        "CAP_NET_ADMIN"
        "CAP_NET_RAW"
        "CAP_NET_BIND_SERVICE"
        "CAP_CHOWN"
      ];
      description = ''
        Linux capabilities retained for AWL when running non-root or when
        systemd hardening is enabled.
      '';
    };

    configFile = mkOption {
      type = types.nullOr (types.either types.path types.str);
      default = null;
      example = literalExpression "config.age.secrets.awl-config.path";
      description = ''
        Optional external config_awl.json source. This is the recommended path
        for agenix, sops-nix, or another secret manager when you want to preserve
        AWL identity material outside the Nix store. The file is copied into
        dataDir before AWL starts because AWL rewrites config_awl.json.
      '';
    };

    settings = mkOption {
      type = jsonFormat.type;
      default = { };
      example = literalExpression ''
        {
          loggerLevel = "info";
          httpListenAddress = "127.0.0.1:8639";
          p2pNode.name = "nix-host";
          vpn = {
            interfaceName = "awl0";
            ipNet = "10.66.0.1/24";
          };
        }
      '';
      description = ''
        Inline AWL configuration rendered to config_awl.json. This is useful for
        non-secret defaults. Do not put p2pNode.identity, HTTP basic-auth
        passwords, SOCKS5 passwords, or other secrets here unless you intend to
        write them into the Nix store.
      '';
    };

    replaceConfig = mkOption {
      type = types.bool;
      default = false;
      description = ''
        If true, copy configFile/settings into dataDir on every service start.
        If false, seed config_awl.json only when it does not already exist.
        The default preserves AWL's mutable peer state.
      '';
    };

    interfaceName = mkOption {
      type = types.str;
      default = "awl0";
      description = ''
        Expected AWL TUN interface name, used for firewall integration. Keep it
        aligned with your AWL config_awl.json vpn.interfaceName setting.
      '';
    };

    loadTunModule = mkOption {
      type = types.bool;
      default = true;
      description = "Load the Linux tun kernel module at boot.";
    };

    installPackage = mkOption {
      type = types.bool;
      default = true;
      description = "Add the AWL package to environment.systemPackages for CLI usage.";
    };

    environment = mkOption {
      type = types.attrsOf types.str;
      default = { };
      example = literalExpression ''{ LIBP2P_DEBUG = "1"; }'';
      description = "Extra environment variables for the AWL daemon.";
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [
        pkgs.inetutils
        pkgs.iproute2
        pkgs.iptables
        pkgs.coreutils
      ];
      defaultText = literalExpression "[ pkgs.inetutils pkgs.iproute2 pkgs.iptables pkgs.coreutils ]";
      description = ''
        Packages added to the AWL service PATH. AWL is mostly self-contained;
        these tools are useful for interface helpers and diagnostics.
      '';
    };

    limitNOFILE = mkOption {
      type = types.int;
      default = 4000;
      description = "systemd LimitNOFILE for AWL.";
    };

    firewall = {
      trustInterface = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Add services.awl.interfaceName to networking.firewall.trustedInterfaces.
          Convenient, but broad. Strict hosts should prefer allowedTCPPorts and
          allowedUDPPorts.
        '';
      };

      allowedTCPPorts = mkOption {
        type = types.listOf types.port;
        default = [ ];
        example = [
          22
          443
        ];
        description = "TCP ports allowed on the AWL interface.";
      };

      allowedUDPPorts = mkOption {
        type = types.listOf types.port;
        default = [ ];
        example = [ 53 ];
        description = "UDP ports allowed on the AWL interface.";
      };
    };

    hardening = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Apply conservative systemd hardening. Disabled by default because AWL
          needs network, TUN, DNS, and interface privileges. Enable after basic
          connectivity works.
        '';
      };

      readWritePaths = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "Additional writable paths when hardening is enabled.";
      };
    };

    extraServiceConfig = mkOption {
      type = types.attrs;
      default = { };
      example = literalExpression ''{ RestartSec = "10s"; }'';
      description = "Extra systemd serviceConfig merged after module defaults.";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      assertions = [
        {
          assertion = !(cfg.configFile != null && hasInlineSettings);
          message = "services.awl: use either configFile or settings, not both.";
        }
      ];

      warnings = optional hasInlineSettings ''
        services.awl.settings is written to the Nix store. Do not put AWL
        identity material or passwords there unless that is intentional. For
        secrets, use services.awl.configFile from agenix, sops-nix, or similar.
      '';

      boot.kernelModules = mkIf cfg.loadTunModule [ "tun" ];
      environment.systemPackages = mkIf cfg.installPackage [ cfg.package ];

      users.groups = mkIf (cfg.createUser && cfg.group != "root") {
        ${cfg.group} = { };
      };

      users.users = mkIf (cfg.createUser && cfg.user != "root") {
        ${cfg.user} = {
          isSystemUser = true;
          group = cfg.group;
          home = cfg.dataDir;
          createHome = false;
        };
      };

      systemd.tmpfiles.rules = [
        "d ${cfg.dataDir} 0700 ${cfg.user} ${cfg.group} - -"
      ];

      systemd.services.awl = {
        description = "Anywherelan headless mesh VPN daemon";
        documentation = [ "https://github.com/anywherelan/awl" ];
        wantedBy = [ "multi-user.target" ];
        wants = [
          "network-online.target"
          "nss-lookup.target"
        ];
        after = [
          "network-online.target"
          "nss-lookup.target"
        ];
        path = cfg.extraPackages;

        preStart = ''
          set -eu
          install -d -m 0700 -o ${escapeShellArg cfg.user} -g ${escapeShellArg cfg.group} ${dataDirArg}

          ${optionalString hasConfigSource ''
            if [ ${if cfg.replaceConfig then "1" else "0"} -eq 1 ] || [ ! -s ${configTargetArg} ]; then
              install -m 0600 -o ${escapeShellArg cfg.user} -g ${escapeShellArg cfg.group} ${configSourceArg} ${configTmpArg}
              mv -f ${configTmpArg} ${configTargetArg}
            fi
          ''}
        '';

        serviceConfig = mkMerge [
          {
            Type = "simple";
            ExecStart = "${cfg.package}/bin/awl";
            WorkingDirectory = cfg.dataDir;
            Environment = environment;
            Restart = "always";
            RestartSec = "5s";
            LimitNOFILE = cfg.limitNOFILE;
            User = cfg.user;
            Group = cfg.group;
            UMask = "0077";

            # preStart may need to read root-owned secret files before dropping
            # to a non-root runtime user.
            PermissionsStartOnly = true;
          }
          capabilitiesConfig
          hardeningConfig
          cfg.extraServiceConfig
        ];
      };
    }

    (mkIf cfg.firewall.trustInterface {
      networking.firewall.trustedInterfaces = [ cfg.interfaceName ];
    })

    (mkIf
      (
        !cfg.firewall.trustInterface
        && (cfg.firewall.allowedTCPPorts != [ ] || cfg.firewall.allowedUDPPorts != [ ])
      )
      {
        networking.firewall.interfaces.${cfg.interfaceName} = {
          allowedTCPPorts = cfg.firewall.allowedTCPPorts;
          allowedUDPPorts = cfg.firewall.allowedUDPPorts;
        };
      }
    )
  ]);
}
