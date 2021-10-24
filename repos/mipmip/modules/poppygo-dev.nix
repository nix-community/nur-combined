{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    mipmip_pkg.embgit
  ]
  ++ (if pkgs.stdenv.isDarwin then
  [
  ]
  else
  [
  ]
  );
}
