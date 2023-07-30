{ pkgs }:

let
  inherit (pkgs) mkShell flacon flac shntool sops ssh-to-age;

in {
  flac = mkShell { buildInputs = [ flacon flac shntool ]; };
  sops-env = mkShell { buildInputs = [ sops ssh-to-age ]; };
}

