{ global, config, pkgs, ... }:
let
  inherit (pkgs) i3lock-color;
  inherit (global) wallpaper;

  locker = pkgs.writeShellScript "locker" ''
    ${i3lock-color}/bin/i3lock-color -B 5 --image ${toString wallpaper} --tiling --ignore-empty-password --show-failed-attempts --clock --pass-media-keys --pass-screen-keys --pass-volume-keys
  '';
in
{
  services.xserver = {
    enable = true;
    displayManager.defaultSession = "xfce+i3";
    desktopManager = {
      xterm.enable = false;
      xfce = {
        enable = true;
        noDesktop = true;
        enableXfwm = false;
      };
    };
    windowManager.i3.enable = true;
  };
  programs.xss-lock = {
    enable = true;
    lockerCommand = "${locker}";
    extraOptions = [];
  };
  environment.systemPackages = [
    pkgs.xfce.xfce4-xkb-plugin
  ];
}
