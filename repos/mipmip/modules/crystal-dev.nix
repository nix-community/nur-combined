{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    crystal
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
