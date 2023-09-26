{ lib, stdenv, pkgs, fetchurl, ... }:
pkgs.xorriso.overrideAttrs (old: {
  preInstall = ''
    substituteInPlace "xorriso-dd-target/xorriso-dd-target" \
      --replace "xdt_init ||" "xdt_lsblk_cmd=${pkgs.util-linux}/bin/lsblk;xdt_dd_cmd=${pkgs.coreutils}/bin/dd;xdt_umount_cmd=${pkgs.umount}/bin/umount ||"
  '';
})

