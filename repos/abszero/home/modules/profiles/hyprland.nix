{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkIf;
  inherit (lib.abszero.modules) mkExternalEnableOption;
  cfg = config.abszero.profiles.hyprland;
in

{
  imports = [ ./full.nix ];

  options.abszero.profiles.hyprland.enable = mkExternalEnableOption config "hyprland profile";

  config = mkIf cfg.enable {
    abszero = {
      profiles.full.enable = true;
      wayland.windowManager.hyprland.enable = true;
      services.hypridle.enable = true;
      programs = {
        hyprlock.enable = true;
        foot.enable = true;
      };
    };

    services.hyprpaper.enable = true;

    home.packages = with pkgs; [
      albert
      grimblast
      brillo
    ];
  };
}
