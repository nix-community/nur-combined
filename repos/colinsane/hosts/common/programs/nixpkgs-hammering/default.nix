{ config, pkgs, ... }:
{
  sane.programs.nixpkgs-hammering = {
    packageUnwrapped = pkgs.nixpkgs-hammering.override {
      nix = config.sane.programs.nix.package;
    };

    sandbox.whitelistPwd = true;
    sandbox.extraPaths = [
      "/nix/var"  # to prevent complaints about it not finding build logs
    ];
  };
}
