{
  lib,
  pkgs,
  ...
}:

{
  # Home Manager has no equivalent of the NixOS `utils` module argument.
  _module.args.nixosUtils = import ../../lib/nixos-utils.nix {
    inherit lib;
    nixpkgs = pkgs.path;
  };
}
