{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.tun2socks;
  serviceOptions = pkgs.nur.repos.dukzcry.lib.systemd.default // {
    DeviceAllow = "/dev/net/tun";
    RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6 AF_NETLINK";
    AmbientCapabilities = "CAP_NET_ADMIN";
    CapabilityBoundingSet = "CAP_NET_ADMIN";
    DynamicUser = true;
  };
in {
  options = {
    programs.tun2socks = {
      enable = mkEnableOption ''
        tun2socks
      '';

      gateways = mkOption {
        type = types.attrsOf (types.submodule {
          options = {
            address = mkOption {
              type = types.str;
              example = "10.0.1.1/24";
            };
            proxy = mkOption {
              type = types.str;
              example = "socks5://127.0.0.1:9050";
            };
            logLevel = mkOption {
              type = types.str;
              default = "info";
            };
          };
        });
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services = (mapAttrs' (name: value: nameValuePair "tun2socks-${name}" ({
      description = "tun2socks ${name}";
      path = with pkgs.nur.repos.dukzcry; [ tun2socks ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = pkgs.writeShellScript "tun2socks" ''
          tun2socks -device tun://${name} -proxy ${value.proxy} -loglevel ${value.logLevel}
        '';
      } // serviceOptions;
    })) cfg.gateways) //
    (mapAttrs' (name: value: nameValuePair "tun2socks-${name}-script" ({
      after = [ "sys-devices-virtual-net-${name}.device" ];
      bindsTo = [ "sys-devices-virtual-net-${name}.device" ];
      wantedBy = [ "sys-devices-virtual-net-${name}.device" ];
      description = "tun2socks ${name} script";
      path = with pkgs; [ iproute2 ];
      serviceConfig = {
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "tun2socks-start" ''
          set +e
          ip addr add ${value.address} dev ${name}
          ip link set dev ${name} up

          ip rule add from ${value.address} table ${name}
          ip route add default dev ${name} table ${name}
          ip rule add from ${value.address} table main suppress_prefixlength 0
          true
        '';
        ExecStop = pkgs.writeShellScript "tun2socks-stop" ''
          set +e
          ip rule del from ${value.address} table ${name}
          ip route del default dev ${name} table ${name}
          ip rule del from ${value.address} table main suppress_prefixlength 0
          true
        '';
      };
    })) cfg.gateways);
    networking.iproute2.enable = true;
    networking.iproute2.rttablesExtraConfig = concatStringsSep "\n" (
      imap1 (i: v: "${toString i} ${v}") (attrNames cfg.gateways)
    );
  };
}
