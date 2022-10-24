{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    bat
    tldr
    cheat
    httpie
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
