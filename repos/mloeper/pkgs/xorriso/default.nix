{ lib, stdenv, pkgs, fetchurl, ... }:
pkgs.xorriso.overrideAttrs (old: {
  version = "${old.version}-patched";

  src = fetchurl {
    url = "mirror://gnu/xorriso/xorriso-${old.version}.tar.gz";
    sha256 = "sha256-eG+fXfmGXMWwwf7O49LA9eBMq4yahZvRycfM1JZP2uE=";
  };

  preInstall = ''
    substituteInPlace "xorriso-dd-target/xorriso-dd-target" \
      --replace "xdt_init ||" "xdt_lsblk_cmd=${pkgs.util-linux}/bin/lsblk;xdt_dd_cmd=${pkgs.coreutils}/bin/dd;xdt_umount_cmd=${pkgs.umount}/bin/umount ||"
  '';
})

