{config, lib, pkgs, ...}:
let
  cfg = config.services.readsb;
in {
  options = {
    services.readsb = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = lib.mdDoc ''
        Whether readsb is enabled
        '';
      };

      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.callPackage ./package.nix {};
        defaultText = lib.literalExpression "pkgs.readsb";
        description = lib.mdDoc ''
        Which readsb package to use.
        '';
      };

      options = lib.mkOption {
        type = with lib.types; attrsOf (oneOf [str int float bool]);
        default = {
          device = 0;
          device-type = "rtlsdr";
          gain = -10;
          ppm = 0;
          max-range = 450;
          write-json-every = 1;
          net = true;
          net-heartbeat = 60;
          net-ro-size = 1250;
          net-ro-interval = 0.05;
          net-ri-port = 30001;
          net-ro-port = 30002;
          net-sbs-port = 30003;
          net-bi-port = "30004,30104";
          net-bo-port = 30005;
          json-location-accuracy = 2;
          range-outline-hours = 24;
          no-interactive = true;
          quiet = true;
        };
        description = lib.mdDoc ''
        Readsb arguments
        '';
      };

      openFirewallOutput = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = lib.mdDoc ''
        Whether output firewall ports (30002, 30003, 30005) should be opened
        '';
      };

      openFirewallInput = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = lib.mdDoc ''
        Whether input firewall ports (30001, 30004, 30104) should be opened
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    hardware.rtl-sdr.enable = true;
    # https://github.com/sdr-enthusiasts/gitbook-adsb-guide/blob/main/setting-up-rtl-sdrs/blacklist-kernel-modules.md
    boot.blacklistedKernelModules = [ "dvb_usb_v2" "dvb_usb_rtl2832u" "r820t" "rtl2830" "rtl2832" "rtl2832_sdr" "rtl2838" "rtl8192cu" "rtl8xxxu" ];

    networking.firewall.allowedTCPPorts = lib.optionals cfg.openFirewallInput [ 30001 30004 30104 ]
      ++ lib.optionals cfg.openFirewallOutput [ 30002 30003 30005 ];

    systemd.services.readsb = {
      description = "readsb ADS-B receiver";
      documentation = [ "https://github.com/wiedehopf/readsb" ];
      wants = [ "network.target" ];
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      
      serviceConfig = let 
        args = lib.cli.toGNUCommandLineShell {} cfg.options;
      in {
        Type = "simple";
        Restart = "on-failure";
        RestartSec = 30;
        DynamicUser = true;
        SupplementaryGroups = [ "dialout" "plugdev" ];
        
        ExecStart = "${cfg.package}/bin/readsb ${args} --write-json /run/readsb";
        
        RuntimeDirectory = "readsb";
        RuntimeDirectoryMode = "0755";
        Nice = -5;

        # Sandboxing
        ProtectProc = "invisible"; # Allow /proc but only to our process
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        PrivateDevices = false; # Allow /dev
        ProtectHostname = true;
        # ProtectClock = true; # Allow USB device reading ???
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        RestrictNamespaces = true;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RemoveIPC = true;
        SystemCallArchitectures = "native";
      };
    };
  };
}
