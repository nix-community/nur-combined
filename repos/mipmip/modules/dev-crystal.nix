{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    crystal
    shards
    crystal2nix
    mipmip_pkg.crelease
  ];
}
