# This file has been generated by node2nix 1.9.0. Do not edit!

{ nixosVersion
, pkgs ? import <nixpkgs> {
    inherit system;
},
system ? builtins.currentSystem,
nodejs ? pkgs."nodejs-18_x"
}:

let
  nodeEnv = import ./node-env.nix {
    inherit (pkgs) stdenv lib python2 runCommand writeTextFile writeShellScript;
    inherit pkgs nodejs;
    libtool = if pkgs.stdenv.isDarwin then pkgs.darwin.cctools else null;
  };
  src = pkgs.fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "tfk-api-unoconv";
    rev = "17bcb8b48198ac78e3ae9ce6ef4692c227c72f90";
    sha256 = "sha256-19SVYSmb36OSjt4mvNXFploQDdcKZ4e/tyQECagj/AE=";
  };
in
(import ./node-packages.nix {
  inherit (pkgs) fetchurl nix-gitignore stdenv lib fetchgit;
  inherit nodeEnv src;
}).package


