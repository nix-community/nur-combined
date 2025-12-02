# Full desktop (PC)
{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkIf;
  inherit (lib.abszero.modules) mkExternalEnableOption;
  cfg = config.abszero.profiles.desktop;
in

{
  imports = [ ./graphical-full.nix ];

  options.abszero.profiles.desktop.enable = mkExternalEnableOption config "desktop profile";

  config = mkIf cfg.enable {
    abszero.profiles.graphical-full.enable = true;
    environment.systemPackages = with pkgs; [
      osu-lazer-bin
    ];
  };
}
