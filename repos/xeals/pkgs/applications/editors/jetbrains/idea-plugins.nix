{ lib, stdenv, fetchzip }:

self:

let

  ideaBuild = import ../../../build-support/jetbrains/plugin.nix {
    inherit lib stdenv fetchzip;
    jetbrainsPlatforms = [ "idea-community" "idea-ultimate" ];
  };

  generateIdea = lib.makeOverridable ({
    idea ? ./manual-idea-packages.nix
  }: let

    imported = import idea {
      inherit (self) callPackage;
    };

    super = imported;

    overrides = { };

    ideaPlugins = super // overrides;

  in ideaPlugins // { inherit ideaBuild; });

in generateIdea { }

