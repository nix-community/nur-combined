{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.wireguird;
in
{
  options = {
    programs.wireguird = {
      enable = lib.mkEnableOption "wireguird, a WireGuard GUI";
      package = lib.mkPackageOption pkgs "wireguird" { };
      group = lib.mkOption {
        type = lib.types.str;
        default = "wireguard";
        description = ''
          Group allowed to manage WireGuard tunnels with wireguird.
          Add users with `users.users.<name>.extraGroups = [ "${cfg.group}" ];`.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    users.groups.${cfg.group} = { };

    # wireguird uses wg to query connection status
    security.wrappers.wg = {
      owner = "root";
      group = cfg.group;
      capabilities = "cap_net_admin+eip";
      permissions = "u+rx,g+x";
      source = "${pkgs.wireguard-tools}/bin/wg";
    };

    # wireguird uses wg-quick to start/stop connections
    # wg-quick automatically attempts to use sudo if it is not root
    # We grant passwordless sudo to the group so the GUI connects seamlessly
    security.sudo.extraRules = [
      {
        groups = [ cfg.group ];
        commands = [
          {
            command = "${pkgs.wireguard-tools}/bin/wg-quick";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };

  meta.maintainers = [ ];
}
