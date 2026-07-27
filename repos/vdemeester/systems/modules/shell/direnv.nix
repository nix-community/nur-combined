{ config, lib, pkgs, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.modules.shell.direnv;
in
{
  options.modules.shell.direnv = {
    enable = mkEnableOption "enable direnv";
  };
  config = mkIf cfg.enable {
    programs.direnv.enable = true;
    environment = {
      # Path to link from packages to /run/current-system/sw
      pathsToLink = [
        "/share/nix-direnv"
      ];
      systemPackages = [ pkgs.direnv ];
    };
  };
}
