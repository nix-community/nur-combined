{ self, ... }:

let
  default-overlays = import "${self}/overlays";

  additional-overlays = {
    # Expose my expanded library
    lib = final: prev: { inherit (self) lib; };

    # Expose my custom packages
    pkgs = final: prev: {
      ambroisie = prev.recurseIntoAttrs (import "${self}/pkgs" { pkgs = prev; });
    };
  };
in
default-overlays // additional-overlays
