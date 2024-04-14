{ lib, pkgs, ... }@args:
# make /srv/* attach options
with lib;
{
  config =
    foldl'
      (
        acc: elem:
        acc
        // (
          let
            p = (import ../srv/${elem}.nix args);
          in
          (optionalAttrs (p.enable) (p.attach or { }))
        )
      )
      { }
      (
        map (removeSuffix ".nix") (
          lib.subtractLists [ "default.nix" ] (with builtins; attrNames (readDir ../srv))
        )
      );
}
