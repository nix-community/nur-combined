# Entry point for the Nix User Repository.
#
# nix-community/NUR points at this file (`file` in its repos.json), so
# everything a NUR consumer can reach is what this attribute set exposes:
#
#     nur.repos.mopigamesyt.mlos-host-utils
#     nur.repos.mopigamesyt.modules.mlos-host-utils
#     nur.repos.mopigamesyt.overlays.mlos-host-utils
#
# NUR evaluates it with `pkgs` supplied; the default is only so that
# `nix-build packaging/nix/nur.nix -A mlos-host-utils` works by hand.
{
  pkgs ? import <nixpkgs> { },
}:

let
  overlay = final: _prev: {
    mlos-host-utils = final.callPackage ./package.nix { };
  };
in
{
  mlos-host-utils = pkgs.callPackage ./package.nix { };

  overlays.mlos-host-utils = overlay;

  # The module's `package` option defaults to `pkgs.mlos-host-utils`, which
  # nixpkgs does not have -- so the module handed to NUR consumers brings the
  # overlay that puts it there.  Importing it is then the whole setup.
  modules.mlos-host-utils = {
    imports = [ ./module.nix ];
    nixpkgs.overlays = [ overlay ];
  };
}
