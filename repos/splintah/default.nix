{ pkgs ? import <nixpkgs> {} }:
{
  # home-manager modules
  hmModules = import ./hm-modules;

  id3 = pkgs.callPackage ./pkgs/id3 { };
  mopidy-podcast = pkgs.callPackage ./pkgs/mopidy-podcast { };
  ocamlweb = pkgs.callPackage ./pkgs/ocamlweb { };
  onedrive = pkgs.callPackage ./pkgs/onedrive { };
}
