{config, pkgs, ...}:
{
  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = import ./packages.nix;
  };
}

