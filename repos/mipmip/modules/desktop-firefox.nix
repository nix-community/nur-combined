{ config, lib, pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
    firefox
  ];

  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
  };

}
