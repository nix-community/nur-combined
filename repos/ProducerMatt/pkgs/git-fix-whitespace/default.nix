{ lib, fetchFromGitHub, pkgs, stdenv }:

let
  version = "2016-04-27";
in
stdenv.mkDerivation {
  name = "git-fix-whitespace-${version}";

  src = fetchFromGitHub {
    owner = "RichardBronosky";
    repo = "git-fix-whitespace";
    rev = "b87dc31761ce3cd44a06a46b236314a66dfb3243";
    hash = "sha256-+ArzzYCbxV9f0cTRkxZ4JtXcNVsuwkNSOytc790dmQA=";
  };

  buildInputs = with pkgs; [
    bash
    git
    coreutils
  ];
  phases = [ "installPhase" ];

  installPhase = ''
    mkdir $out
    mkdir $out/bin
    cp $src/git-fix-whitespace $out/bin
    patchShebangs $out/bin/git-fix-whitespace
  '';
}
