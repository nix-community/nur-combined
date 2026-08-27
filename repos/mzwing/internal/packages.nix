# The repository's package set; the only definition of how packages are assembled.
{pkgs}: let
  sources = pkgs.callPackage ../_sources/generated.nix {};

  # Keep npm lockfile repair scoped to packages in this repository, and let callPackage resolve buildGoApplication.
  packagePkgs = pkgs.extend (
    pkgs.lib.composeExtensions
    (import ./npm-lockfile-fix.nix)
    (import ((import ./gomod2nix.nix) + "/overlay.nix"))
  );
in
  (import ./discover.nix {inherit (pkgs) lib;}).packages {
    pkgs = packagePkgs;
    inherit sources;
    dir = ../pkgs;
    # Auto-wiring exceptions.
    extraArgs.typenix-vscode = {source = sources.typenix;};
  }
