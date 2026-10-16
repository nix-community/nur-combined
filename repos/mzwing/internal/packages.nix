# The repository's package set; the only definition of how packages are assembled.
{pkgs}: let
  # Keep npm lockfile repair scoped to packages in this repository, and let callPackage resolve buildGoApplication.
  packagePkgs = pkgs.extend (
    pkgs.lib.composeExtensions
    (import ./npm-lockfile-fix.nix)
    (import ((import ./gomod2nix.nix) + "/overlay.nix"))
  );
in
  (import ./discover.nix {inherit (pkgs) lib;}).packages {
    pkgs = packagePkgs;
    dir = ../pkgs;
  }
