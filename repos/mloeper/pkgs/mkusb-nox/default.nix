{ lib, stdenv, pkgs, fetchFromGitHub, ... }:

stdenv.mkDerivation {
  pname = "mkusb-nox";
  version = "23.1.2";

  src = fetchFromGitHub
    {
      owner = "sudodus";
      repo = "tarballs";
      rev = "93b43c208e902d0f8064b3b0abf461765b273a53";
      sha256 = "sha256-FcI/GKLjhIN0YxXNxE6bagGyQ7o9SwtHfIonrXc4EkE=";
    };

  buildInputs = with pkgs; [
    pv
  ];

  nativeBuildInputs = with pkgs; [
    xz
  ];

  unpackPhase = ":";
  installPhase = ''
    install -d $out/bin
    tar -xf $src/mkusb-nox.tar.xz
    cp mkusb-nox $out/bin/mkusb-nox
  '';

  meta = with lib; {
    homepage = "https://help.ubuntu.com/community/mkusb/v7";
    description = "Copy an ISO file to a USB device";
    license = licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "mkusb-nox";
  };
}
