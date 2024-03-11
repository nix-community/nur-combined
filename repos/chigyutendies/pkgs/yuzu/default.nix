{ qt6Packages, makeScopeWithSplicing', generateSplicesForMkScope, branch }:
let
  compat-list = qt6Packages.callPackage ./compat-list.nix {};
  nx_tzdb = qt6Packages.callPackage ./nx_tzdb.nix {};
  mainline = qt6Packages.callPackage ./mainline.nix {inherit compat-list; inherit nx_tzdb;};
  in
{
  inherit mainline;
  early-access = qt6Packages.callPackage ./early-access {inherit mainline;};

}.${branch}
