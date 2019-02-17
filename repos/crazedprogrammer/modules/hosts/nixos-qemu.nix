{ config, lib, pkgs, ... }:

{
  imports = [
    ../home
  ];

  networking.hostName = "nixos-qemu";

  # programs.sway-beta.enable = true;
  # services.xserver.windowManager.session = [{
  #   name = "sway-beta";
  #   start = ''
  #     sway &
  #     waitPID=$!
  #   '';
  # }];
}
