{ inputs, ... }:
{
  perSystem =
    { pkgs, system, ... }:
    let
      defaultNix = pkgs.lib.filesystem.packagesFromDirectoryRecursive {
        inherit (pkgs) callPackage newScope;
        directory = ../pkgs;
      };
      flattenPkgs = (import ../lib/flatten.nix { inherit pkgs; });
      flakePackages = flattenPkgs defaultNix;
      warnPackages =
        if system != "x86_64-linux" then
          pkgs.lib.warn "dtomvan/nur-packages: only x86_64-linux builds are tested, use at own risk" flakePackages
        else
          flakePackages;
    in
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config = {
          enableCuda = false; # causes build failure for nix
          allowUnfree = true;
        };
      };
      legacyPackages = warnPackages;
      packages = pkgs.lib.filterAttrs (_: pkgs.lib.isDerivation) warnPackages;
    };
}
