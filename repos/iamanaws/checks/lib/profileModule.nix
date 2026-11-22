{ lib, flakeRoot, ... }:
let
  profileModule = import (flakeRoot + "/lib/profileModule.nix");
  profiles = flakeRoot + "/nixos/profiles";
  resolve =
    profile:
    profileModule {
      inherit lib profile;
      name = "profile-check";
      profilesDir = profiles;
    };
in
assert resolve null == null;
assert resolve "core" == profiles + "/core.nix";
assert resolve "desktop" == profiles + "/desktop.nix";
assert resolve "vm/virtualbox" == profiles + "/vm/virtualbox.nix";
assert
  profileModule {
    inherit lib;
    name = "directory-profile-check";
    profilesDir = ./fixtures/profiles;
    profile = "defaulted";
  } == ./fixtures/profiles/defaulted;
assert lib.all (profile: !(builtins.tryEval (resolve profile)).success) [
  ""
  "deskotp"
  "vm"
  "vm/does-not-exist"
  "/desktop"
  "./desktop"
  "../core"
  "vm/../desktop"
  "vm//virtualbox"
  "vm/virtualbox/"
];
true
