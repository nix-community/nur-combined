{ lib, stdenv, pkgs, fetchurl, appimageTools, libpng, gnutls, ... }:

let
  pname-base = "rancher-desktop";
  version = "1.13.1";
in
appimageTools.wrapType2 {
  inherit version;
  pname = "${pname-base}-wrapped";

  src = fetchurl {
    url = "https://download.opensuse.org/repositories/isv:/Rancher:/dev/AppImage/rancher-desktop-9.main.1715995959.97aaae25-Build2223.1.glibc2.29-x86_64.AppImage";
    hash = "sha256-ElX2Orpxy1wbhmEYgARnvmgRd1xarlXIDrMtyUL2uso=";
  };

  extraPkgs = pkgs: with pkgs; [
    libsecret
    libpng
    gnutls
  ];
}
