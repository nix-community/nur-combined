{ lib, stdenv, variant }:

self:

let

  ideaBuild = import ../../../build-support/jetbrains/plugin.nix {
    inherit lib stdenv variant;
    jetbrainsPlatforms = [ "idea-community" "idea-ultimate" ];
  };

  generateIdea = lib.makeOverridable ({
    generated ? ./idea-generated.nix
  }: let

    imported = import generated {
      inherit (self) callPackage;
    };

    super = imported;

    overrides = { };

    ideaPlugins = super // overrides;

  in ideaPlugins // { inherit ideaBuild; });

in generateIdea { }
