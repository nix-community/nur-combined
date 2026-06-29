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
      group = lib.mkOption {
        type = lib.types.str;
        default = "wireguard";
        description = "Group that is allowed to run wireguird and configure the network.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.wireguird ];

    users.groups."${cfg.group}" = { };

    security.wrappers.wireguird = {
      owner = "root";
      group = cfg.group;
      # wireguird needs to run wireguard commands and create interfaces, so we use setuid.
      setuid = true;
      source = "${pkgs.wireguird}/bin/wireguird";
    };
  };

  meta.maintainers = [ ];
}
