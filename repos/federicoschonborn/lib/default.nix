{
  pkgs ? import <nixpkgs> { },
}:

pkgs.lib.extend (
  _: prev: { maintainers = prev.maintainers // import ../maintainers/maintainers-list.nix; }
)
