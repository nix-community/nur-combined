{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    bat
    tldr
    cheat
    xh
    duf
  ]
  ++ (if pkgs.stdenv.isDarwin then
  [
  ]
  else
  [
  ]
  );
}
