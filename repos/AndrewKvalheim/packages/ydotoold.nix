# Requires uinput group created by KMonad module
{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkIf mkOption;
  inherit (lib.types) package;

  cfg = config.services.ydotoold;
in
{
  options.services.ydotoold = {
    enable = mkEnableOption "ydotool daemon";
    package = mkOption { type = package; default = pkgs.ydotool; };
  };

  config = mkIf cfg.enable {
    users.groups.ydotool = { };

    users.users.ydotool = {
      description = "ydotool daemon";
      group = "ydotool";
      isSystemUser = true;
    };

    systemd.tmpfiles.rules = [ "d /run/ydotool - ydotool ydotool -" ];

    systemd.services.ydotoold = {
      wantedBy = [ "multi-user.target" ]; # Pending NixOS/nixpkgs#169143
      description = "ydotool daemon";
      serviceConfig.User = "ydotool";
      serviceConfig.SupplementaryGroups = [ "uinput" ];
      script = "${cfg.package}/bin/ydotoold --socket-path /run/ydotool/ydotool.sock --socket-perm 0660";
    };
  };
}
