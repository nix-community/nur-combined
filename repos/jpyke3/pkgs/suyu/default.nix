{ qt6Packages, makeScopeWithSplicing', generateSplicesForMkScope, branch }:
let
  compat-list = qt6Packages.callPackage ./compat-list.nix {};
  nx_tzdb = qt6Packages.callPackage ./nx_tzdb.nix {};
in
{
    
    dev = qt6Packages.callPackage ./dev.nix {inherit compat-list; inherit nx_tzdb;};
    #beta?
    #alpha?
    #master?

}.${branch}
