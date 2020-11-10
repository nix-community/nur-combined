{ pkgs, nodejs, stdenv, lib, ... }:

let
  nodePackages = import ./node-composition.nix {
    inherit pkgs nodejs;
    inherit (stdenv.hostPlatform) system;
  };
in
nodePackages.oorja.override {
  name = "teletype";

  buildInputs = [
    pkgs.nodePackages.node-gyp-build
  ];

  meta = with lib; {
    description = "stream terminals to the web and more.";
    homepage = "https://teletype.oorja.io/";
    license = licenses.asl20;
  };
}
