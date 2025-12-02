{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (builtins) readDir warn;
  inherit (lib) mkEnableOption mkPackageOption mkIf;
  cfg = config.abszero.services.rclone;
in

{
  imports = [
    (
      if (readDir ./. ? "file-systems.nix") then
        ./file-systems.nix
      else
        warn "file-systems.nix is hidden, configuration is incomplete" { }
    )
  ];

  options.abszero.services.rclone = {
    enable = mkEnableOption "network storage client and server daemon";
    package = mkPackageOption pkgs "rclone" { };
  };

  config = mkIf cfg.enable {
    # Make mount use rclone as a mount helper
    systemd.tmpfiles.rules = [ "L /sbin/mount.rclone - - - - /run/current-system/sw/bin/rclone" ];

    environment.systemPackages = [ cfg.package ];
  };
}
