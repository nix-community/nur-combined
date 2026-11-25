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
  dbus,
  pkg-config,
  makeWrapper,
  gnumake,
}:

let
  version = "0.1.8";
in
rustPlatform.buildRustPackage {
  pname = "rustel";
  inherit version;

  src = fetchFromGitHub {
    owner = "tzfm";
    repo = "rustel";
    rev = "b561fb5ef3d455d8f6eeee1637f9cf7af6fa447b";
    hash = "sha256-jjg6rRic4gUyUh+iYMA+lG98apHCDL6PQ4Bj+cEInfw=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "crossterm-0.29.0" = "sha256-gRcW327QHV11/V6q8URzvFCpsQkItdHml4L8/EtMLfg=";
      "rquickjs-0.14.0" = "sha256-TN+vf/LCPHv8v+daszuYLcANgOSs1jmwO1DlgUQd1C8=";
      "rquickjs-core-0.14.0" = "sha256-TN+vf/LCPHv8v+daszuYLcANgOSs1jmwO1DlgUQd1C8=";
      "rquickjs-macro-0.14.0" = "sha256-TN+vf/LCPHv8v+daszuYLcANgOSs1jmwO1DlgUQd1C8=";
      "rquickjs-sys-0.14.0" = "sha256-TN+vf/LCPHv8v+daszuYLcANgOSs1jmwO1DlgUQd1C8=";
      "pulseaudio-0.3.2" = "sha256-ZXJfa85d+kADapuVZDoY59SCt4IEqlRGQs8OMkjpTkg=";
      "rustel-hydra-0.2.3" = "sha256-xVmiYfJk4jxyev9U7vAWzVzluho6XVwpuiWcOjzqUAA=";
      "rustel-studio-themes-0.2.0" = "sha256-I/sMNtf5+HIHD3fo5T+VYnxd2vS0AxNOmAfj2WSvVu0=";
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
    dbus
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
