{ stdenv, fetchgit, writeShellScript, pkgs, lib }:

let
  python-with-packages = pkgs.python39.withPackages(ps: with ps; [ psutil ]);
in
stdenv.mkDerivation rec {
  pname = "lol-launchhelper";
  version = "1";

  src = fetchgit {
    url = "https://github.com/CakeTheLiar/launchhelper";
    sha256 = "sha256-uqZzDWUJTC2sYR5prAEjQbPX3sr5eqZ3q4iB7W9ilSw=";
  };

  nativeBuildInputs = [
    python-with-packages
  ];

  meta = with lib; {
    description = "A helper for the League Of Legends launcher on Linux to run faster.";
    homepage = https://github.com/CakeTheLiar/launchhelper;
    changelog = "https://github.com/CakeTheLiar/launchhelper/commits/master";
    platforms = platforms.linux;
  };

  helper = writeShellScript "lol-launchhelper.sh" ''
  ${python-with-packages}/bin/python ${src}/launchhelper2.py
  '';

  installPhase = ''
  install -Dm755 ${helper} $out/bin/lol-launchhelper
  '';
}
