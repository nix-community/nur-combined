{ pkgs, lib, config, options, ... }:
with lib;

let
  cfg = config.services.readarr;

in
{
  options = {
    services.readarr = {
      enable = mkEnableOption "Readarr";

      package = mkOption {
        type = types.package;
        default = pkgs.readarr;
        defaultText = literalExpression "pkgs.readarr";
        description = "Readarr package to use";
      };

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

  config = mkIf cfg.enable {
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
        ExecStart = "${cfg.package}/bin/Readarr -nobrowser -data='${cfg.dataDir}'";
        Restart = "on-failure";
      };
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ 8787 ];
    };

    users.users = mkIf (cfg.user == "readarr") {
      readarr = {
        group = cfg.group;
        home = "/var/lib/readarr";
        uid = config.ids.uids.readarr;
      };
    };

    users.groups = mkIf (cfg.group == "readarr") {
      readarr = {
        gid = config.ids.gids.readarr;
      };
    };
  };
}
