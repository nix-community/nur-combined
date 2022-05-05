{ pkgs, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "ncpamixer-git";
  version = "1.3.3.1-git";

  src = fetchFromGitHub {
    owner = "fulhax";
    repo = "ncpamixer";
    rev = "4faf8c27d4de55ddc244f372cbf5b2319d0634f7";
    sha256 = "sha256-ElbxdAaXAY0pj0oo2IcxGT+K+7M5XdCgom0XbJ9BxW4=";
  };

  nativeBuildInputs = [ pkgs.gnumake pkgs.cmake ];

  buildInputs = [ pkgs.ncurses pkgs.libpulseaudio ];

  configurePhase = ''
      make PREFIX=$out USE_WIDE=1 RELEASE=1 build/Makefile
  '';
}
