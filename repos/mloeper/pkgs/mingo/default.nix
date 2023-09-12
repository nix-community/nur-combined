{ lib, stdenv, pkgs, fetchurl, appimageTools, ... }:

appimageTools.wrapType2 {
  name = "Mingo";
  version = "1.13.3";
  src = fetchurl {
    url = "https://github.com/mingo-app/mingo/releases/download/v1.13.3/Mingo-1.13.3.AppImage";
    hash = "sha256-VVVHcWnoZxlgzL13EnCKcymyas4CqfyLptcI8raT7PA=";
  };
  extraPkgs = pkgs: with pkgs; [
    libsecret
  ];
}
