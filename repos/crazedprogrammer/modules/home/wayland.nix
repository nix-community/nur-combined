{ config, pkgs, ... }:

let
  swayExtraConfig = ''
    # No mouse accelleration
    input 1133:49283:Logitech_G403_Prodigy_Gaming_Mouse accel_profile flat

    input * xkb_layout "${config.services.xserver.layout}"
    input * xkb_options "${config.services.xserver.xkbOptions}"
    input * repeat_delay "${builtins.toString config.services.xserver.autoRepeatDelay}"
    input * repeat_rate "${builtins.toString (1000 / config.services.xserver.autoRepeatInterval)}"

    output * background /home/casper/Pictures/Background.png tile
  '';
  swayConfigFile = pkgs.writeText "sway-config"
    ''
      ${builtins.readFile ../../dotfiles/sway-config}
      ${swayExtraConfig}
    '';
in

{
  # Enable sway window manager.
  programs.sway = {
    enable = true;
  };
  services.xserver.displayManager.extraSessionFilePackages = [
    (pkgs.sway-session.override { configFile = swayConfigFile; })
  ];
}
