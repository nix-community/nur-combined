{ pkgs ? import ../../../nix { } }:
pkgs.npmlock2nix.v2.build {
  src = ./.;
  buildCommands = [ "echo BUILDING" ];
  installPhase = "mkdir $out";
}
