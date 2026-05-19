{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.profiles.laptop;
in

{
  imports = [ ./graphical-full.nix ];

  options.abszero.profiles.laptop.enable = mkEnableOption "laptop profile";

  config = mkIf cfg.enable {
    abszero.profiles.graphical-full.enable = true;

    services = {
      scx.extraArgs = [ "--autopower" ]; # Adjust power mode based on system EPP
      upower = {
        enable = true;
        percentageLow = 30;
        percentageCritical = 10;
        # Disable polling for hardware that pushes events
        noPollBatteries = true;
      };
    };

    environment.systemPackages = with pkgs; [
      krita
    ];
  };
}
