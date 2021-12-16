{ pkgs ? import <nixpkgs> {} }:

let
  pkgs' = pkgs.extend (import ./overlay.nix);
in

{
  inherit (pkgs') vimExtraPlugins;
}
