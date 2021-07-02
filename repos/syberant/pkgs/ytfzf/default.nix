{ lib, stdenv, fetchFromGitHub, makeWrapper, curl, ncurses, mpv, youtube-dl, fzf, jq }:

stdenv.mkDerivation {
  pname = "ytfzf";
  version = "1.1.2";

  src = fetchFromGitHub {
    owner = "pystardust";
    repo = "ytfzf";
    rev = "d98dfd4c8056cadc2fe663f1fe26d859195ff471";
    sha256 = "FwSMBaYcPKUZ4GoeEWIXes9mDeKiGeJr0KOlQ04pXyU=";
  };

  # The Makefile won't work for us
  dontBuild = true;

  nativeBuildInputs = [ makeWrapper ];
  installPhase = ''
    mkdir -p $out/bin
    cp $src/ytfzf $out/bin/ytfzf

    wrapProgram $out/bin/ytfzf --set PATH ${lib.makeBinPath ([ mpv youtube-dl fzf jq ncurses curl] ++ stdenv.initialPath)}
  '';
}
