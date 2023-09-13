{ lib, stdenv, pkgs, fetchurl, appimageTools, ... }:

appimageTools.wrapType2 {
  pname = "mingo";
  version = "1.13.3";

  src = fetchurl {
    url = "https://github.com/mingo-app/mingo/releases/download/v1.13.3/Mingo-1.13.3.AppImage";
    hash = "sha256-VVVHcWnoZxlgzL13EnCKcymyas4CqfyLptcI8raT7PA=";
  };

  extraPkgs = pkgs: with pkgs; [
    libsecret
  ];

  meta = with lib; {
    homepage = "https://mingo.io/";
    description = "The best MongoDB GUI Admin. Intuitive • Fast • Secure";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "Mingo";
  };
}
