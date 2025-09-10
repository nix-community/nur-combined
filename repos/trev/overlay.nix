# You can use this file as a nixpkgs overlay. This is useful in the
# case where you don't want to add the whole NUR namespace to your
# configuration.
final: prev: let
  nurAttrs = import ./default.nix {pkgs = prev;};
in {
  trev = nurAttrs;
}
