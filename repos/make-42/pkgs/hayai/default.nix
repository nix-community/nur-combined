{
  stdenv,
  fetchurl,
  lib,
  pkgs,
  fetchFromGitHub,
  buildGoModule,
}:
buildGoModule rec {
  pname = "hayai";
  version = "0.0.1";

  buildInputs = with pkgs; [
    alsa-lib
    gtk3
    gcc
    go
    pkg-config
  ];

  nativeBuildInputs = with pkgs; [pkg-config makeWrapper];

  subPackages = ["."];

  src = fetchFromGitHub {
    owner = "make-42";
    repo = "hayai";
    rev = "5dbea7f1964b4cad2f1cadf0539cbc15f1fe9409";
    hash = "sha256-wFo/pFQ3B5cwSkCsl7g2HZRApV77XdQ2QNwKgPqvkJE=";
  };

  vendorHash = null;

  meta = with lib; {
    description = "An EEW system for Linux using JMA data provided by the Wolfx Project.";
    homepage = "https://github.com/make-42/hayai";
    license = licenses.gpl3;
    maintainers = [];
    platforms = platforms.linux;
  };

  postInstall = ''
    wrapProgram "$out/bin/hayai" \
    --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [
      pkgs.pkg-config
      pkgs.alsa-lib
      pkgs.gtk3
    ]}
  '';
}
