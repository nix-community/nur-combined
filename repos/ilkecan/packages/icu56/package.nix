{
  stdenv,
  lib,
  buildPackages,
  fetchurl,
  fixDarwinDylibNames,
  path,
  testers,
  updateAutotoolsGnuConfigScriptsHook,
}:

let
  make-icu = (import (path + /pkgs/development/libraries/icu/make-icu.nix)) {
    inherit
      stdenv
      lib
      buildPackages
      fetchurl
      fixDarwinDylibNames
      testers
      updateAutotoolsGnuConfigScriptsHook
      ;
  };
in
(make-icu {
  version = "56.1";
  hash = "sha256-OmTpEFxzTc9jHAs+1gQEUxvObA9aZL/hpkAqTMIxSBY=";
}).overrideAttrs
  {
    __structuredAttrs = true;
    strictDeps = true;
  }
