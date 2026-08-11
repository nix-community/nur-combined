# You can use this file as a nixpkgs overlay. This is useful in the
# case where you don't want to add the whole NUR namespace to your
# configuration.

_self: super:
let
  nurAttrs = import ./default.nix { pkgs = super; };
in
super.lib.filterAttrs (n: _v: n != "lib" && n != "modules" && n != "overlays") nurAttrs
