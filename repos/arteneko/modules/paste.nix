{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.paste;
in {
  options.services.paste = {
    enable = mkEnableOption ''
      Paste, a small temporary redis-based pastebin server.
      '';

    package = mkOption {
      type = types.package;
      default = pkgs.nur.repos.arteneko.paste;
      defaultText = "pkgs.nur.repos.arteneko.paste";
      description = "The paste package to use";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.paste = let
      pkg = pkgs.nur.repos.arteneko.paste;
      user = "paste";
      group = "paste";
    in {
      description = "Paste ephemeral pastebin server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" "network-online.target" ];
      path = [ pkg ];

      serviceConfig = {
        ExecStart = "${pkg}/bin/paste";
        WorkingDirectory = "${pkg}/lib/paste";
        Restart = "on-failure";
        DynamicUser = true;

        # Security options
        AmbientCapabilities = "";
        CapabilityBoundingSet = "";
        DeviceAllow = ""; # ProtectClock= adds DeviceAllow=char-rtc r
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        RestrictNamespaces = true;
        RestrictAddressFamilies = [ "AF_INET" "AF_INET6" ];
        RestrictRealtime = true;
        PrivateTmp = true;
        PrivateDevices = true;
        PrivateUsers = true;
        LockPersonality = true;
      };
    };
  };
}
