self:
{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.multicast-relay;
  package = self.legacyPackages.${pkgs.system}.multicast-relay;
in
{
  options.services.multicast-relay = with types; mkOption {
    type = types.submodule {
      options = {
        enable = mkEnableOption "multicast-relay";
        interfaces = mkOption {
          type = types.listOf types.str;
          default = [ ];
          description = ''
            Interfaces to listen on
          '';
        };
        extraConfig = mkOption {
          type = types.str;
          default = "";
          description = ''
            Extra config to apply
          '';
        };
        user = mkOption {
          type = str;
          default = "multicast-relay";
          description = ''
            User to run the service under
          '';
        };
        group = mkOption {
          type = str;
          default = "multicast-relay";
          description = ''
            Group of user to run the service under
          '';
        };

      };
    };
  };

  config = mkIf cfg.enable {
    users.users."${cfg.user}" = {
      description = "multicast-relay user";
      isSystemUser = true;
      group = "${cfg.group}";
    };
    users.groups."${cfg.group}" = { };

    systemd.services."multicast-relay" = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        Restart = "always";
        PrivateTmp = true;
        WorkingDirectory = "/tmp";
        DynamicUser = false;
        AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" "CAP_NET_BROADCAST" "CAP_NET_RAW" ];
        User = cfg.user;
        Group = cfg.group;
        ExecStart = ''
          ${getBin package}/bin/multicast-relay \
          --interfaces ${builtins.concatStringsSep " " cfg.interfaces} \
          --foreground \
          ${cfg.extraConfig}
        '';
      };
    };
  };
}
