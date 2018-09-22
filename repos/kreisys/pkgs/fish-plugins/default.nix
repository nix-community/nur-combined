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

    # TODO: fetch those two from their actual sources?
    iterm2-integration = packagePlugin {
      name =  "iterm2-integration";
      src  = ./iterm2-integration;
    };

    docker-completions = packagePlugin {
      name =  "docker-completions";
      src  = ./docker-completions;
    };

  };
in self
