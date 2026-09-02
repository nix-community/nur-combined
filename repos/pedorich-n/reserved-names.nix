# Names reserved by the NUR combiner — see
# https://github.com/nix-community/NUR/blob/master/flake.nix
#
# Keep this list in sync with the NUR spec. Any change here must also be
# reflected in:
#   - ci.nix (builds cache)
#   - overlays/default.nix (pkgs overlay)
#   - flake-parts/packages.nix (flake.packages.<system>)
#   - flake-parts/modules.nix (flake.modules.nixos)
[
  "lib"
  "overlays"
  "nixosModules"
  "homeModules"
  "darwinModules"
  "flakeModules"
]
