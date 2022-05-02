{ lib, fetchFromGitHub, stdenv, xorg }:

stdenv.mkDerivation rec {
  name = "warpd";
  version = "unstable-2022-05-01";

  src = fetchFromGitHub {
    owner = "rvaiya";
    repo = name;
    rev = "133b8a2bd99359baa826c424f90afe3d93434527";
    sha256 = "sha256-7xPlRn+fMJaaAYHrn6JzcEV771I6wgakd9zetf+vic4=";
  };

  buildInputs = with xorg; [
    libXi
    libXinerama
    libXft
    libXfixes
    libXtst
    libX11
    libXext
  ];

  installPhase = ''
    mkdir -p $out/{bin,share/man/man1}
    install -m644 warpd.1.gz $out/share/man/man1/
    install -m755 bin/warpd $out/bin/
  '';

  meta = with lib; {
    description = "A modal keyboard-driven virtual pointer";
    homepage = "https://github.com/rvaiya/warpd";
    platforms = platforms.linux;
  };
}
