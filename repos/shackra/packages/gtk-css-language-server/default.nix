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
  vala,
  meson,
  ninja,
  pkg-config,
  gtk4,
  jsonrpc-glib,
  json-glib,
  git,
  lib,
}:

stdenv.mkDerivation {
  pname = "gtk-css-language-server";
  version = "2023.12";

  src = fetchFromGitHub {
    owner = "JCWasmx86";
    repo = "GTKCssLanguageServer";
    rev = "dcbe75012d2d26fbca2729cee014e4860e31fa53";
    sha256 = "sha256-KKC5ZLIjCAgC/Qp1AhAGLWlxM/yApEfAL8ppHmSBb74=";
  };

  nativeBuildInputs = [
    vala
    meson
    ninja
    pkg-config
    gtk4
    jsonrpc-glib
    json-glib
    git
  ];

  configurePhase = ''
    meson setup build --prefix=$out
  '';

  buildPhase = ''
    ninja -C build
  '';

  installPhase = ''
    ninja -C build install
  '';

  meta = with lib; {
    description = "Language server for GTK CSS";
    homepage = "https://github.com/JCWasmx86/GTKCssLanguageServer";
    license = licenses.gpl3;
    maintainers = with maintainers; [ shackra ];
    platforms = platforms.linux ++ platforms.darwin;
    mainProgram = "gtkcsslanguageserver";
  };
}
