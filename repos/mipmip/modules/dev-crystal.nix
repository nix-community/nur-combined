{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    crystal
    shards
    crystal2nix
    mipmip_pkg.crelease
  ]
  ++ (if pkgs.stdenv.isDarwin then
  [
  ]
  else
  [
  ]
  );
}
