# You can use this file as a nixpkgs overlay. This is useful in the
# case where you don't want to add the whole NUR namespace to your
# configuration.
inputs: self: super:
let
  isReserved = n: n == "lib" || n == "overlays" || n == "modules";
  nameValuePair = n: v: {
    name = n;
    value = v;
  };
  nurAttrs = import ./packages.nix {
    pkgs = super;
    inherit inputs;
  };

in
builtins.listToAttrs (
  map (n: nameValuePair n nurAttrs.${n}) (
    builtins.filter (n: !isReserved n) (builtins.attrNames nurAttrs)
  )
)
