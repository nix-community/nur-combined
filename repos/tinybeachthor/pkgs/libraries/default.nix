{ pkgs, ... }:

with pkgs;
{
  libpd = pkgs.callPackage ./libpd { };
  libphonon = pkgs.callPackage ./libphonon { };
  libinstpatch = pkgs.callPackage ./libinstpatch { };
}
