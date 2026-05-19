# Full desktop (PC)
{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.profiles.desktop;
in

{
  imports = [ ./graphical-full.nix ];

  options.abszero.profiles.desktop.enable = mkEnableOption "desktop profile";

  config = mkIf cfg.enable {
    abszero = {
      profiles.graphical-full.enable = true;
      virtualisation.libvirtd.enable = true;
    };

    environment.systemPackages = with pkgs; [
      osu-lazer-bin
    ];
  };
}
