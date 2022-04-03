{ pkgs, lib, config, options, ... }:

let
  cfg = config.services.readarr;
in

{
  options = with lib; {
    services.readarr = {
      enable = mkEnableOption "Readarr";

      dataDir = mkOption {
        type = types.str;
        default = "/var/lib/readarr/.config/Readarr";
        description = "The directory where Readarr stores its data files.";
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Open ports in the firewall for the Readarr web interface
        '';
      };

      user = mkOption {
        type = types.str;
        default = "readarr";
        description = "User account under which Readarr runs.";
      };

      group = mkOption {
        type = types.str;
        default = "readarr";
        description = "Group under which Readarr runs.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d '${cfg.dataDir}' 0700 ${cfg.user} ${cfg.group} - -"
    ];

    systemd.services.readarr = {
      description = "Readarr";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        ExecStart = "${pkgs.readarr}/bin/Readarr -nobrowser -data='${cfg.dataDir}'";
        Restart = "on-failure";
      };
    };

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ 8787 ];
    };

    users.users = lib.mkIf (cfg.user == "readarr") {
      readarr = {
        group = cfg.group;
        home = "/var/lib/readarr";
        uid = config.ids.uids.readarr;
      };
    };

    users.groups = lib.mkIf (cfg.group == "readarr") {
      readarr = {
        gid = config.ids.gids.readarr;
      };
    };
  };
}
