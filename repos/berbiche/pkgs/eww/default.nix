{ lib, callPackage }:

let
  base = import ./base.nix;
in
{
  wayland = callPackage (base {
    withWayland = true;
    cargoHash = "sha256-RkEenIGqhJrUeFQ1KtaiPbvhohG2Uk2Ojd6+nsZP79s=";
  }) { };
  x11 = callPackage (base {
    withWayland = false;
    cargoHash = "sha256-3XkDyaa49xWmnDjRKdiZFZmXkbwbYzoVHiYQg73XqgY=";
  }) { };
}
