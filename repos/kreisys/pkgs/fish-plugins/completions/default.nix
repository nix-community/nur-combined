{ newScope, packagePlugin }:

let
  callPackage = newScope self;

  self = rec {
    inherit packagePlugin;
    docker         = callPackage ./docker.nix         {};
    docker-compose = callPackage ./docker-compose.nix {};
  };
in self
