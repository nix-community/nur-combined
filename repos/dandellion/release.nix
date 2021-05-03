{ pkgs ? <nixos-unstable> }:
{
  buildPkgs = (import ./ci.nix {}).buildPkgs;
}
