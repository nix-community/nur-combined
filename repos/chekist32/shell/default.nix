{ pkgs }:
let
  generate-obsidian-plugins = import ./generate-obsidian-plugins.nix { inherit pkgs; };
in
{
  inherit generate-obsidian-plugins;
}
