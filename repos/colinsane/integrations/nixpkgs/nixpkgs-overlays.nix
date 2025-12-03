# this file exists so i can use my custom packages inside `nix-shell`.
# it works by using stock upstream `nixpkgs`
# and putting NIX_PATH=nixpkgs-overlays=/path/to/here on the nixbld environment.
#
# XXX(2024-08-12): DON'T import `all.nix`, as that makes upstreaming cross patches more difficult (impurity)!
# i only really need to grant access to my additional packages, here.
# import ../../overlays/all.nix
import ../../overlays/pkgs.nix
