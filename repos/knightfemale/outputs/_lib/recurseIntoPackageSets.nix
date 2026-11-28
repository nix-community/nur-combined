{
  lib,
}:

let
  inherit (lib)
    isAttrs
    isDerivation
    mapAttrs
    recurseIntoAttrs
    ;

  self =
    set:
    recurseIntoAttrs (
      mapAttrs (
        _: value: if isAttrs value && !isDerivation value && !(value ? __functor) then self value else value
      ) set
    );
in
self
