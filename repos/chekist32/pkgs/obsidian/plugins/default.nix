{ pkgs }:
let
  mkObsidianPlugin = pkgs.callPackage ./mk-obsidian-plugin.nix { };
  plugins = import ./plugins.nix { inherit mkObsidianPlugin; };
in
plugins
