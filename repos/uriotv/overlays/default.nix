{
  # Default overlay that adds all packages from this NUR repository
  # Note: vintagestory is NOT included - it requires version and hash arguments
  # Use the NixOS module or manual override instead
  default = final: prev: {
    cybergrub2077 = final.callPackage ../pkgs/cybergrub2077 { };
    optipatcher-install = final.callPackage ../pkgs/optipatcher-install { };
    optiscaler-client = final.callPackage ../pkgs/optiscaler-client { };
    optiscaler-install = final.callPackage ../pkgs/optiscaler-install { };
    rimsort-appimage = final.callPackage ../pkgs/rimsort-appimage { };
    rimsort = final.rimsort-appimage;
    scopebuddy = final.callPackage ../pkgs/scopebuddy { };
    vs-launcher = final.callPackage ../pkgs/vs-launcher { };
    wowup-cf = final.callPackage ../pkgs/wowup-cf { };
  };
}
