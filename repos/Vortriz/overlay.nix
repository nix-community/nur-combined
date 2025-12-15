# You can use this file as a nixpkgs overlay. This is useful in the
# case where you don't want to add the whole NUR namespace to your
# configuration.

_self: super:
let
    isReserved = n: n == "lib" || n == "overlays" || n == "modules";
    excludedPkgs = [ "librusty_v8" ];
    nameValuePair = n: v: {
        name = n;
        value = v;
    };
    nurAttrs = import ./default.nix { pkgs = super; };

in
(map (n: nameValuePair n nurAttrs.${n}) (
    builtins.filter (n: !isReserved n) (builtins.attrNames nurAttrs)
))
|> builtins.listToAttrs
|> (p: builtins.removeAttrs p excludedPkgs)
