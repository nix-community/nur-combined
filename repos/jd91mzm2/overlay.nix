# You can use this file as a nixpkgs overlay. This is useful in the
# case where you don't want to add the whole NUR namespace to your
# configuration.

# This file is from
# https://github.com/nix-community/nur-packages-template/tree/2610a5b60bd926cea3e6395511da8f0d14c613b9. Any
# changes should be commented on. As of right now, it's unchanged.

self: super:

let

  isReserved = n: n == "lib" || n == "overlays" || n == "modules";
  nameValuePair = n: v: { name = n; value = v; };
  nurAttrs = import ./default.nix { pkgs = super; };

in

  builtins.listToAttrs
  (map (n: nameValuePair n nurAttrs.${n})
  (builtins.filter (n: !isReserved n)
  (builtins.attrNames nurAttrs)))
