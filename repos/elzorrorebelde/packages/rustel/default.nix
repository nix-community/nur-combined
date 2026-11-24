##########################################################################
#                                                                        #
#  This file is part of the elzorrorebelde/nur project                   #
#                                                                        #
#  Copyright (C) 2026 Jorge Javier Araya Navarro                         #
#                                                                        #
#  SPDX-License-Identifier: MIT                                          #
#                                                                        #
##########################################################################

{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  alsa-lib,
  udev,
  pkg-config,
  makeWrapper,
  gnumake,
}:

let
  version = "0.1.6";
in
rustPlatform.buildRustPackage {
  pname = "rustel";
  inherit version;

  src = fetchFromGitHub {
    owner = "tzfm";
    repo = "rustel";
    rev = "refs/tags/v${version}";
    hash = "sha256-p5tPJug6tSLq76MmBvFS0bP9wMpeF9cxOyXIsAomq8U=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "crossterm-0.29.0" = "sha256-gRcW327QHV11/V6q8URzvFCpsQkItdHml4L8/EtMLfg=";
      "rquickjs-0.14.0" = "sha256-TN+vf/LCPHv8v+daszuYLcANgOSs1jmwO1DlgUQd1C8=";
      "rquickjs-core-0.14.0" = "sha256-TN+vf/LCPHv8v+daszuYLcANgOSs1jmwO1DlgUQd1C8=";
      "rquickjs-macro-0.14.0" = "sha256-TN+vf/LCPHv8v+daszuYLcANgOSs1jmwO1DlgUQd1C8=";
      "rquickjs-sys-0.14.0" = "sha256-TN+vf/LCPHv8v+daszuYLcANgOSs1jmwO1DlgUQd1C8=";
      "rustel-hydra-0.1.0" = "sha256-ibcnQt5wVu428vh2hB/gAg7nsyKm7icMgmaAjg1IMPY=";
      "rustel-talkit-0.1.1" = "sha256-mBvB19oCqnqtzxLfoqoHY3uP2ZgyFfcoz4gkxF0SlBA=";
    };
  };

  nativeBuildInputs = [
    pkg-config
    makeWrapper
    gnumake
  ];

  buildInputs = [
    alsa-lib
    udev
  ];

  doCheck = false;

  meta = with lib; {
    description = "A native Rust engine for the Strudel pattern language";
    longDescription = ''
      rustel is a native Rust engine for the Strudel pattern language, a live
      coding environment for algorithmic music. It includes a command-line
      renderer and an interactive terminal studio.
    '';
    homepage = "https://github.com/tzfm/rustel";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ elzorrorebelde ];
    platforms = platforms.linux;
    mainProgram = "rustel";
  };
}
