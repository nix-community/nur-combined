{
  pkgs,
  config,
  lib,
  ...
}:
{
  options = {
    services.rtorrent.enableSandboxSample = lib.mkEnableOption "sandbox sample for rtorrent";
  };

  config = lib.mkIf config.services.rtorrent.enable {
    networking.ports = {
      rtorrent-flood.enable = true;
      rtorrent-dht.enable = true;
      rtorrent-port-0000.enable = true;
      rtorrent-port-0001 = {
        enable = true;
        port = config.networking.ports.rtorrent-port-0000.port + 1;
      };
      rtorrent-port-0002 = {
        enable = true;
        port = config.networking.ports.rtorrent-port-0001.port + 1;
      };
      rtorrent-port-0003 = {
        enable = true;
        port = config.networking.ports.rtorrent-port-0002.port + 1;
      };
      rtorrent-port-0004 = {
        enable = true;
        port = config.networking.ports.rtorrent-port-0003.port + 1;
      };
      rtorrent-port-0005 = {
        enable = true;
        port = config.networking.ports.rtorrent-port-0004.port + 1;
      };
      rtorrent-port-0006 = {
        enable = true;
        port = config.networking.ports.rtorrent-port-0005.port + 1;
      };
      rtorrent-port-0007 = {
        enable = true;
        port = config.networking.ports.rtorrent-port-0006.port + 1;
      };
      rtorrent-port-0008 = {
        enable = true;
        port = config.networking.ports.rtorrent-port-0007.port + 1;
      };
      rtorrent-port-0009 = {
        enable = true;
        port = config.networking.ports.rtorrent-port-0008.port + 1;
      };
      rtorrent-port-9999 = {
        enable = true;
        port = config.networking.ports.rtorrent-port-0009.port + 1;
      };
    };

    networking.firewall.allowedTCPPortRanges = [
      {
        from = config.networking.ports.rtorrent-port-0000.port;
        to = config.networking.ports.rtorrent-port-9999.port;
      }
    ];

    services.rtorrent = {
      downloadDir = "${config.services.rtorrent.dataDir}/Downloads";
      openFirewall = true;
      dataPermissions = lib.mkDefault "0755";
      inherit (config.networking.ports.rtorrent-port-0000) port;
      configText = ''
        protocol.pex.set = yes
        trackers.use_udp.set = yes

        dht = on
        dht_port = ${toString config.networking.ports.rtorrent-dht.port}

        pieces.memory.max.set = 768M

        schedule2 = dht_node_1, 5, 0, "dht.add_node=router.utorrent.com:6881"
        schedule2 = dht_node_2, 5, 0, "dht.add_node=dht.transmissionbt.com:6881"
        schedule2 = dht_node_3, 5, 0, "dht.add_node=router.bitcomet.com:6881"
        schedule2 = dht_node_4, 5, 0, "dht.add_node=dht.aelitis.com:6881"

        network.port_range.set = ${toString config.networking.ports.rtorrent-port-0000.port}-${toString config.networking.ports.rtorrent-port-9999.port}

        # dht.add_node = router.bittorrent.com:6881
      '';
    };

    systemd.services.rtorrent = {
      restartIfChanged = true;

      serviceConfig = {
        MemoryHigh = "1G";
        MemoryMax = "2G";

        # https://github.com/thiagokokada/nix-configs/blob/c069dafd0657efb97e8e0ad7c38fe432c33f012b/nixos/server/rtorrent.nix#L6
        CapabilityBoundingSet = "";
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;

        SystemCallArchitectures = "native";
        SystemCallFilter = [
          "@system-service"
          "~@privileged"
        ];

        TemporaryFileSystem = "/:ro";
        BindReadOnlyPaths = [
          "/nix/store"
          "/etc"
        ];
        BindPaths = [
          "${config.users.users.${config.services.rtorrent.user}.home}"
          config.services.rtorrent.dataDir
          config.services.rtorrent.downloadDir
          "/run/rtorrent"
        ];
      };
    };

    systemd.services.flood-rtorrent = {
      serviceConfig = {
        User = config.services.rtorrent.user;
        Group = config.services.rtorrent.group;
        ExecStart = "${lib.getExe pkgs.flood} --port ${toString config.networking.ports.rtorrent-flood.port} --auth none --rtsocket ${config.services.rtorrent.rpcSocket}";
        Restart = "on-failure";

        CapabilityBoundingSet = "";
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;

        SystemCallArchitectures = "native";
        SystemCallFilter = [ "~@privileged" ];

        TemporaryFileSystem = "/:ro";

        BindReadOnlyPaths = [
          config.services.rtorrent.downloadDir
          "/nix/store"
          "/etc"
        ];
        BindPaths = [
          "${config.users.users.${config.services.rtorrent.user}.home}"
          "/run/rtorrent"
        ];
      };

      restartIfChanged = true;

      environment = {
        NODE_ENV = "production";
      };

      wantedBy = [ "multi-user.target" ];

      after = [ "rtorrent.service" ];
    };

    systemd.services.rtorrent-sandbox-sample.serviceConfig =
      lib.mkIf config.services.rtorrent.enableSandboxSample
        (
          lib.mkMerge [
            config.systemd.services.rtorrent.serviceConfig
            {
              ExecStart = lib.mkForce "/run/rtorrent-poc-payload";
              ExecStartPre = lib.mkForce "";
              RuntimeDirectory = lib.mkForce "rtorrent-sandbox-poc";
              BindPaths = [ "/run" ];
            }
          ]
        );

    services.nginx.virtualHosts."rtorrent.${config.networking.hostName}.${config.networking.domain}" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.networking.ports.rtorrent-flood.port}";
      };
    };
  };
}
