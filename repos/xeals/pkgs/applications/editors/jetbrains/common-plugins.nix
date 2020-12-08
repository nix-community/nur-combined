{ lib, stdenv, fetchzip }:

self:

let

  commonBuild = import ../../../build-support/jetbrains/plugin.nix {
    inherit lib stdenv fetchzip;
    jetbrainsPlatforms = [
      "clion"
      "datagrip"
      "goland"
      "idea-community"
      "idea-ultimate"
      "phpstorm"
      "pycharm-community"
      "pycharm-professional"
      "rider"
      "ruby-mine"
      "webstorm"
    ];
  };

  generateCommon = lib.makeOverridable ({
    common ? ./manual-common-packages.nix
  }: let

    imported = import common {
      inherit (self) callPackage;
    };

    super = imported;

    overrides = { };

    jetbrainsPlugins = super // overrides;

  in jetbrainsPlugins // { inherit commonBuild; });

in generateCommon { }

