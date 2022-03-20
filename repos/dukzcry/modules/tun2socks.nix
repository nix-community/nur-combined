{ config, lib, pkgs, ... }:

with lib;

let
  sleep = dev: "while [ ! -d /sys/devices/virtual/net/${dev} ]; do sleep 5; done";
  cfg = config.programs.tun2socks;
  serviceOptions = {
    LockPersonality = true;
    DeviceAllow = "/dev/net/tun";
    PrivateIPC = true;
    PrivateMounts = true;
    ProtectClock = true;
    ProtectControlGroups = true;
    ProtectHostname = true;
    ProtectKernelLogs = true;
    ProtectKernelModules = true;
    ProtectKernelTunables = true;
    ProtectProc = "invisible";
    RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6 AF_NETLINK";
    RestrictNamespaces = true;
    RestrictRealtime = true;
    AmbientCapabilities = "CAP_NET_ADMIN";
    CapabilityBoundingSet = "CAP_NET_ADMIN";
    MemoryDenyWriteExecute = true;
    SystemCallArchitectures = "native";
    SystemCallFilter = "~@clock @cpu-emulation @debug @keyring @module @mount @obsolete @raw-io @resources";
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
            routedAddress = mkOption {
              type = types.str;
              example = "10.0.0.1/24";
            };
            proxy = mkOption {
              type = types.str;
              example = "socks5://127.0.0.1:9050";
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
          tun2socks -device tun://${name} -proxy ${value.proxy}
        '';
      } // serviceOptions;
    })) cfg.gateways) //
    (mapAttrs' (name: value: nameValuePair ("tun2socks-${name}-script") ({
      after = [ ("tun2socks-${name}.service") ];
      bindsTo = [ ("tun2socks-${name}.service") ];
      wantedBy = [ ("tun2socks-${name}.service") ];
      description = "tun2socks ${name} script";
      path = with pkgs; [ iproute2 ];
      serviceConfig = {
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "tun2socks-start" ''
          set +e
          ${sleep name}
          ip addr add ${value.address} dev ${name}
          ip link set dev ${name} up

          ip rule add from ${value.address} table ${name}
          ip route add default dev ${name} table ${name}
          ip rule add from ${value.address} table main suppress_prefixlength 0
          true
        '';
        ExecStop = pkgs.writeShellScript "tun2socks-stop" ''
        '';
      };
    })) cfg.gateways);
    networking.iproute2.enable = true;
    networking.iproute2.rttablesExtraConfig = concatStringsSep "\n" (
      imap1 (i: v: "${toString i} ${v}") (attrNames cfg.gateways)
    );
  };
}
