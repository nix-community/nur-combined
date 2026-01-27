{
  # Default overlay that adds all packages from this NUR repository
  # Note: vintagestory is NOT included - it requires version and hash arguments
  # Use the NixOS module or manual override instead
  default = final: prev: {
    cybergrub2077 = final.callPackage ../pkgs/cybergrub2077 { };
    wowup-cf = final.callPackage ../pkgs/wowup-cf { };
    scopebuddy = final.callPackage ../pkgs/scopebuddy { };
  };
}
