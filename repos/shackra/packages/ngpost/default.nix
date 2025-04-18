##########################################################################
#                                                                        #
#  This file is part of the shackra/nur project                          #
#                                                                        #
#  Copyright (C) 2025 Jorge Javier Araya Navarro                         #
#                                                                        #
#  SPDX-License-Identifier: MIT                                          #
#                                                                        #
##########################################################################

{
  stdenv,
  fetchFromGitHub,
  qtbase,
  wrapQtAppsHook,
  openssl,
  lib,
  pkg-config,
}:

stdenv.mkDerivation {
  pname = "ngpost";
  version = "4.16";

  src = fetchFromGitHub {
    owner = "mbruel";
    repo = "ngPost";
    rev = "97a84347f1ea548f3fdc4104759552a452be3c2b";
    sha256 = "sha256-orftNEd2yRoKvhx6LSJOOXlGLqWLnkfQGbqpc2ob6p0=";
  };

  nativeBuildInputs = [
    qtbase
    wrapQtAppsHook
    pkg-config
  ];

  buildInputs = [
    qtbase
    openssl
  ];

  buildPhase = ''
    cd src
    qmake -makefile ngPost.pro
    make
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp ngPost $out/bin/
  '';

  meta = with lib; {
    description = "Command Line and sexy GUI Usenet poster for binaries";
    homepage = "https://github.com/mbruel/ngPost";
    license = licenses.gpl3;
    maintainers = with maintainers; [ shackra ];
    platforms = platforms.all;
    mainProgram = "ngPost";
  };
}
