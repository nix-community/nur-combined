{ self, lib, ... }:
let
  default-overlays = import "${self}/overlays";

  additional-overlays = {
    # Expose my expanded library
    lib = _final: _prev: { inherit (self) lib; };

    # Expose my custom packages
    pkgs = _final: prev: {
      ambroisie = lib.recurseIntoAttrs (import "${self}/pkgs" { pkgs = prev; });
    };
  };
in
{
  flake.overlays = default-overlays // additional-overlays;
}
