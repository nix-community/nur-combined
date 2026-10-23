{ lib }:
let
  resolve =
    profile:
    import ../lib/profileModule.nix {
      inherit lib profile;
      name = "profile-check";
      profilesDir = ../nixos/profiles;
    };
in
assert resolve null == null;
assert resolve "core" == ../nixos/profiles/core.nix;
assert resolve "desktop" == ../nixos/profiles/desktop.nix;
assert resolve "vm/virtualbox" == ../nixos/profiles/vm/virtualbox.nix;
assert
  import ../lib/profileModule.nix {
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
