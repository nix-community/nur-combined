{ config, lib, pkgs, ... }:

{
  imports = [
    ../home
  ];

  networking.hostName = "nixos-qemu";
}
