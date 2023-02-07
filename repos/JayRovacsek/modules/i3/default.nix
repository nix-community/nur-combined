{ config, pkgs, ... }: {
  services.xserver.windowManager.i3 = {
    enable = true;
    package = with pkgs; [ i3-gaps ];
  };
}
