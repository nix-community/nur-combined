{pkgs}: let
  lib = pkgs.lib.extend (final: prev: {
    helper = import ./helper.nix {lib = prev;};
    callPackage = pkgs.lib.callPackageWith (pkgs // {lib = final;});
    maintainers = prev.maintainers // import ./maintainers.nix;
  });
in
  lib
