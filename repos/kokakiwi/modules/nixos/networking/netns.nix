{ config, pkgs, lib, ... }:
let
  cfg = config.networking.netns;

  enabledNamespaces = lib.filterAttrs (_: netns: netns.enable) cfg.namespaces;

  namespaceType = with lib; types.submodule ({ name, config, ... }: {
    options = {
      enable = mkEnableOption "Network namespace ${config.name}" // { default = true; };

      name = mkOption {
        type = types.str;
        default = name;
      };

      startScript = mkOption {
        type = types.lines;
        default = "";
      };
      stopScript = mkOption {
        type = types.lines;
        default = "";
      };

      extraPath = mkOption {
        type = with types; listOf package;
        default = [ ];
      };

      serviceBaseName = mkOption {
        type = types.str;
        default = "netns@${config.name}";
      };
      serviceName = mkOption {
        type = types.str;
        readOnly = true;
      };

      namespacePath = mkOption {
        type = types.path;
        readOnly = true;
      };

      dns = mkOption {
        type = with types; listOf str;
        default = [ ];
      };

      veth = {
        enable = mkEnableOption "Network bridge for netns ${config.name}";

        name = mkOption {
          type = types.str;
          default = "veth-${config.name}";
        };

        hostIp = mkOption {
          type = types.str;
        };
        containerIp = mkOption {
          type = types.str;
        };
      };
    };

    config = mkMerge [
      {
        serviceName = "${config.serviceBaseName}.service";
        namespacePath = "/var/run/netns/${config.name}";
      }
      (mkIf config.veth.enable {
        startScript = ''
          ip link add name ${config.veth.name} type veth peer name ${config.veth.name} netns $nsName

          ip addr add ${config.veth.hostIp} dev ${config.veth.name}
          ip -n $nsName addr add ${config.veth.containerIp} dev ${config.veth.name}

          ip link set ${config.veth.name} up
          ip -n $nsName link set ${config.veth.name} up
        '';
      })
    ];
  });

  systemdServiceExtType = with lib; types.submodule ({ config, ... }: {
    options = {
      netns = mkOption {
        type = with types; nullOr str;
        default = null;
      };
    };

    config = let
      netns = cfg.namespaces.${config.netns};
    in mkIf (config.netns != null) {
      bindsTo = [ netns.serviceName ];
      after = [ netns.serviceName ];
      serviceConfig = {
        NetworkNamespacePath = mkDefault netns.namespacePath;
        BindReadOnlyPaths = mkIf (netns.dns != [ ]) [
          "/etc/netns/${netns.name}/resolv.conf:/etc/resolv.conf"
        ];
      };
    };
  });
in {
  options.networking.netns = with lib; {
    namespaces = mkOption {
      type = types.attrsOf namespaceType;
      default = { };
    };
  };
  options.systemd.services = with lib; mkOption {
    type = types.attrsOf systemdServiceExtType;
  };

  config = lib.mkIf (enabledNamespaces != { }) {
    environment.etc = lib.mapAttrs' (_: {
      name,
      dns,
      ...
    }: lib.nameValuePair "netns/${name}/resolv.conf" {
      text = lib.concatMapStringsSep "\n" (address: "nameserver ${address}") dns;
    }) (lib.filterAttrs (_: { dns, ... }: dns != [ ]) enabledNamespaces);

    systemd.services = lib.mapAttrs' (_: {
      name,
      startScript,
      stopScript,
      extraPath,
      serviceBaseName,
      ...
    }: lib.nameValuePair serviceBaseName {
      description = "${name} network namespace";

      before = [ "network.target" ];

      path = [ pkgs.iproute ] ++ extraPath;

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;

        ExecStartPre = "-${pkgs.iproute}/bin/ip netns delete ${name}";
        ExecStart = pkgs.writeShellScript "netns-${name}-up" ''
          set -eo

          nsName="${name}"

          ip netns add $nsName
          ${startScript}
        '';
        ExecStop = pkgs.writeShellScript "netns-${name}-down" ''
          nsName="${name}"

          ${stopScript}
          ip netns delete $nsName
        '';
      };
    }) enabledNamespaces;
  };
}
