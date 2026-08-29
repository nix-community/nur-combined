# You can use this file as a nixpkgs overlay. This is useful in the
# case where you don't want to add the whole NUR namespace to your
# configuration.

_final: prev:
removeAttrs (import ./default.nix { pkgs = prev; }) [
  "lib"
  "modules"
  "overlays"
]
