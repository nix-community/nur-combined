{ config, pkgs, ... }:
with import ../../../globalConfig.nix;
with builtins;
let
  locker = pkgs.writeShellScript "locker" ''
    ${pkgs.i3lock-color}/bin/i3lock-color -B 5 --image ${toString wallpaper} --tiling --ignore-empty-password --show-failed-attempts --clock --pass-media-keys --pass-screen-keys --pass-volume-keys --veriftext="vou ver e te aviso" --wrongtext="errou!" --noinputtext="já entendi que você quer apagar tudo" --locktext="ajeitando os esquema..."
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
