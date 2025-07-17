# You can use this file as a nixpkgs overlay. This is useful in the
# case where you don't want to add the whole NUR namespace to your
# configuration.

self: super:
let
  nurAttrs = import ./default.nix { pkgs = super; };
in
with super.lib;
with nurAttrs.lib;
with builtins;
listToAttrs (
  map (n: nameValuePair n nurAttrs.${n}) (filter (n: !isReserved n) (attrNames nurAttrs))
)
