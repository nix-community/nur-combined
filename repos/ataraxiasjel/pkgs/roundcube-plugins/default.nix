{ pkgs, lib }:
lib.makeScope pkgs.newScope (
  self: with self; {
    roundcubePlugin = callPackage ./roundcube-plugin.nix { };
    carddav = callPackage ./carddav { };
    persistent_login = callPackage ./persistent_login { };
  }
)
