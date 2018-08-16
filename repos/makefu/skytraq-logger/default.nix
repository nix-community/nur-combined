{ stdenv, lib, pkgs, fetchFromGitHub, ... }:
stdenv.mkDerivation rec {
  name = "skytraq-datalogger-${version}";
  version = "4966a8";
  src = fetchFromGitHub {
    owner = "makefu";
    repo = "skytraq-datalogger";
    rev = version ;
    sha256 = "1qaszrs7638kc9x4qq4m1yxqmk8jw7wajywvdk4wc2i007p89v3y";
  };
  buildFlags = "CC=gcc";
  makeFlags = "PREFIX=bin/ DESTDIR=$(out)";

  preInstall = ''
    mkdir -p $out/bin
  '';
  #patchPhase = ''
  #  sed -i -e 's#/usr/bin/gcc#gcc#' -e Makefile
  #'';

  buildInputs = with pkgs;[
    curl
    gnugrep
  ];

  meta = {
    homepage = http://github.com/makefu/skytraq-datalogger;
    description = "datalogger for skytraq";
    license = lib.licenses.gpl2;
  };
}
