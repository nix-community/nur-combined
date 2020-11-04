{ pkgs ? import <nixpkgs> }:
with builtins;
let
  specs = fromJSON (readFile ./voidrice.json);
in
pkgs.fetchgit {
  url = "https://github.com/LukeSmithxyz/voidrice";
  rev = specs.rev;
  sha256 = specs.sha256;
}
