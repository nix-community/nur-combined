# You can use this file as a nixpkgs overlay. This is useful in the
# case where you don't want to add the whole NUR namespace to your
# configuration.

_: prev:

let
  isReserved = n: n == "lib" || n == "overlays" || n == "modules";
  nurAttrs = import ./. {
    inherit (prev) system lib;
    pkgs = prev;
  };
in

builtins.listToAttrs (
  builtins.map (name: {
    inherit name;
    value = nurAttrs.${name};
  }) (builtins.filter (n: !isReserved n) (builtins.attrNames nurAttrs))
)
