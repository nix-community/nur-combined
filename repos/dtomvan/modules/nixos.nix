{ self, ... }:
{
  flake.nixosModules = {
    koil = ../nixos-modules/koil.nix;
    olive_c = ../nixos-modules/olive_c.nix;
  };

  flake.overlays.default = _final: prev: self.packages.${prev.stdenv.hostPlatform.system};
}
