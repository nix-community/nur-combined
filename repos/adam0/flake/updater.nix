_: {
  perSystem = {pkgs, ...}: let
    inherit (pkgs.lib) getExe;
  in {
    # The updater runs nix-update from the locked nixpkgs rather than the
    # floating registry. Nix 2.35 reports a `nix flake metadata` store path
    # without copying the flake there, so nix-update's getFlake call fails;
    # drop the override once a Nix release copies the flake again.
    apps.nix-update = {
      type = "app";
      program = getExe (pkgs.nix-update.override {nix = pkgs.nixVersions.nix_2_34;});
      meta.description = "nix-update pinned to a Nix that materialises flake sources";
    };
  };
}
