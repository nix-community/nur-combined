{ pkgs ? import <nixpkgs> { }
, self
}:
{
  linguee-api = import ./linguee-api.nix { inherit self pkgs; };
}
