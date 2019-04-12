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

  pkgs' = listDirectory (p: pkgs.callPackage p {}) ./pkgs;
in pkgs' // {
  pkgs = pkgs';
  home-modules = listDirectory (x: x) ./home-modules;
}
