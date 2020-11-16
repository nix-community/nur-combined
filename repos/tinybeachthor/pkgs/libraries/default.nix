{ pkgs, ... }:

with pkgs;
{
  libpd = pkgs.callPackage ./libpd { };
}
