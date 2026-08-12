{ pkgs, lib, ... }:

{
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_6_18;
}
