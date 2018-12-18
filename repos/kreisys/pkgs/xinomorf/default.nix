{ pkgs    ? import <nixpkgs> {}
, lib     ? pkgs.lib
, src     ? builtins.getEnv "PWD"
, name    ? if lib.isDerivation src then src.name else builtins.baseNameOf src
, filter  ? _: _: true
, vars    ? {}
, modules ? {}
}:

let
  callPackage = pkgs.newScope self;
  self = rec {
    inherit src name filter vars modules;
    inherit (callPackage ./pkgs {}) wrapper shell cli;
    inherit (import ./lib { inherit lib; }) terraformStubs;
  };
in self
