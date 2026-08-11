/*
nix-build -E 'with import <nixpkgs> { }; callPackage ./default.nix { }'
./result/bin/srtgen
*/

{
  pkgs ? import <nixpkgs> {}
}:

let
  python = pkgs.python3;
  buildPythonPackage = python.pkgs.buildPythonPackage;
  lib = pkgs.lib;
  fetchFromGitHub = pkgs.fetchFromGitHub;
in

buildPythonPackage rec {
  pname = "srtgen";
  version = "0.1.0";
  src = fetchFromGitHub {
    # https://github.com/milahu/srtgen
    owner = "milahu";
    repo = "srtgen";
    rev = "1e279a1172c0379d6339ee61f2b5c0e9954667c9";
    sha256 = "9x7qRbJktA8SBXsWj1In+mb2E8WP8YO9KxCyHcCAJpE=";
  };
  propagatedBuildInputs = with python.pkgs; [
    pydub
    google-cloud-speech
    setuptools # workaround https://github.com/NixOS/nixpkgs/pull/162173
    #SpeechRecognition
  ];
  postInstall = ''
    mv -v $out/bin/srtgen.py $out/bin/srtgen
  '';
  meta = with lib; {
    homepage = "https://github.com/milahu/srtgen";
    description = "Generate subtitles for video file";
    license = licenses.mit;
  };
}
