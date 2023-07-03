{ config, lib, pkgs, inputs, ... }:

{
  security.pam.services.swaylock = {
    text = ''
      auth include login
    '';
  };
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };
  services.xserver = {
    enable = true;
    layout = "us";
    xkbVariant = "colemak";
    displayManager = {
      defaultSession = "sway";
      sddm.enable = true;
    };
  };
}
