{ pkgs ? import <nixpkgs> {} }:

let
  listDirectory = with builtins; action: dir:
    let
      list = readDir dir;
    in listToAttrs (map
      (name: {
        name = replaceStrings [".nix"] [""] name;
        value = action (dir + ("/" + name));
      })
      (attrNames list));

  callPackage = (pkgs.extend (self: super: pkgs')).callPackage;
  pkgs' = listDirectory (p: callPackage p {}) ./pkgs;
in pkgs' // {
  pkgs = pkgs';
  home-modules = listDirectory (x: x) ./home-modules;
}
