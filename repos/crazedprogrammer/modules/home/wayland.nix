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
    output DVI-D-1 mode 1920x1080@60.000000Hz scale 1 pos 0 0
    output DP-1 mode 1920x1080@144.001007Hz scale 1 pos 1920 0
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

  services.dbus.socketActivated = true;
}
