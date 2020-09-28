{ pkgs ? import <nixpkgs> }:

pkgs.fetchgit {
  url = "https://github.com/LukeSmithxyz/voidrice";
  rev = "b768fc601e9b587aa800cd0656a8eee170bd1c93";
  sha256 = "1i35n0qfh0llfg1b8la9yj7qsycwlmipgfp6k1yz9r27gjll768z";
}
