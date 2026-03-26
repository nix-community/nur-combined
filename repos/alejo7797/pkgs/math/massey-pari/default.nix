{ pkgs }:

let
  massey-pari-git = import ./yy { inherit pkgs; };
in

massey-pari-git.overrideAttrs {

  version = "0-unstable-2026-02-09";

  src = pkgs.fetchFromGitHub {
    owner = "ericahlqvist";
    repo = "Massey-pari";
    rev = "337fca9ca9d7ba6f62611fc040804fe75a22cf31";
    hash = "sha256-xNfu0XZm0zZHJcF3+lSCmxxWF0aV9B6yUEtFhsMLPPU=";
  };

}
