# this file exists so i can use my custom packages inside `nix-shell`.
# it works by using stock upstream `nixpkgs`
# and putting NIX_PATH=nixpkgs-overlays=/path/to/here on the nixbld environment.
#
[(import ../../overlays/all.nix)]
