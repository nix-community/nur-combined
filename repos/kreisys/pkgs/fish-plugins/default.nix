{ lib, newScope, fetchgit }:

let
  callPackage = newScope self;

  self = rec {
    packagePlugin = { name, src }: callPackage ./package-plugin.nix { inherit name src; };

    bobthefish = let
      inherit (lib.importJSON ./bobthefish.json) url rev sha256;
    in packagePlugin {
      name = "bobthefish-${rev}";
      src  = fetchgit { inherit url rev sha256; };
    };

    iterm2-integration = callPackage ./iterm2-integration.nix { };

    # TODO: split to docker- and docker-compose- completions and fetch from original source
    docker-completions = packagePlugin {
      name =  "docker-completions";
      src  = ./docker-completions;
    };
  };
in self
