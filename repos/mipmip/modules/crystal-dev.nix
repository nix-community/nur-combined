{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    crystal
    shards
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
