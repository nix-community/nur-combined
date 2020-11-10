{ pkgs, nodejs, stdenv, lib, ... }:

let
  nodePackages = import ./node-composition.nix {
    inherit pkgs nodejs;
    inherit (stdenv.hostPlatform) system;
  };
in
nodePackages.actions-cli.override {
  meta = with lib; {
    description = "Monitor your GitHub Actions in real time from the command line";
    homepage = "https://github.com/remorses/actions-cli";
    license = licenses.isc;
  };
}
