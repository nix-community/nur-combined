# This is the file for my NUR Repo
# Reminder for myself: Any package here should not import <nixpkgs>, but use the pkgs

{ pkgs ? import <nixpkgs> { } }: {
  cbm = pkgs.callPackage ./mods/cbm.nix {};
  mac-telnet = pkgs.callPackage ./mods/mac-telnet.nix {};
}
