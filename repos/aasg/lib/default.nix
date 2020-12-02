{ lib }:
let
  callLibs = file: import file { inherit lib; aasgLib = self; };
  self = rec {
    attrsets = callLibs ./attrsets.nix;
    inherit (attrsets)
      capitalizeAttrNames
      concatMapAttrs'
      copyAttrsByPath
      recurseIntoAttrsRecursive
      updateNew
      updateNewRecursive;

    declarativeEnvironments = callLibs ./declarative-env.nix;
    inherit (declarativeEnvironments) declareEnvironment baseEnvironment;

    extended = import ./extension.nix { inherit lib; };

    lists = callLibs ./lists.nix;
    inherit (lists) indexOf isSubsetOf;

    math = callLibs ./math.nix;
    inherit (math) abs pow;

    strings = callLibs ./strings.nix;
    inherit (strings) capitalize parseHex;
  };
in
self
