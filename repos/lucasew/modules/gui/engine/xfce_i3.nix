{ config, pkgs, ... }:
let
  locker = pkgs.writeShellScript "locker" ''
    ${pkgs.i3lock-color}/bin/i3lock-color --image ~/.background-image --tiling --ignore-empty-password --show-failed-attempts --clock --pass-media-keys --pass-screen-keys --pass-volume-keys --veriftext="vou ver e te aviso" --wrongtext="errou!" --noinputtext="já entendi que você quer apagar tudo" --locktext="ajeitando os esquema..."
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
    xautolock = {
      enable = true;
      time = 10;
      killtime = 24 * 60;
      locker = "${locker}";
    };
  };
  environment.systemPackages = [
    pkgs.xfce.xfce4-xkb-plugin
  ];
}
