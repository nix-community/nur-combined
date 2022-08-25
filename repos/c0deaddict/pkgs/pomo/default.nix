{ lib, stdenv, fetchFromGitHub, makeWrapper, libnotify, coreutils, bats }:

let
    path = [
      libnotify
      coreutils
    ];
in

stdenv.mkDerivation rec {
  pname = "pomo";
  version = "8458b5e6a10e7a09c53dba8253bd15daa2815860";

  src = fetchFromGitHub {
    owner = "jsspencer";
    repo = pname;
    rev = version;
    sha256 = "sha256-Fs9qyOUwuEoGzUTPxU1OeTgdS4Zh0KqULkvG+wFKouM=";
  };

  buildInputs = [ makeWrapper ];
  checkInputs = [ bats ] ++ path;
  doCheck = true;

  patchPhase = ''
    patchShebangs pomo.sh
  '';

  checkPhase = ''
    bats tests -x --verbose-run
  '';

  installPhase = ''
    mkdir -p $out/bin
    install -Dm755 pomo.sh $out/bin/pomo

    wrapProgram $out/bin/pomo --prefix PATH : ${lib.makeBinPath path}
  '';

  meta = with lib; {
    description = "A simple Pomodoro timer written in bash";
    homepage = "https://github.com/jsspencer/pomo";
    license = licenses.mit;
    maintainers = [ maintainers.c0deaddict ];
  };
}
