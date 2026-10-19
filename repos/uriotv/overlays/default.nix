{
  # Default overlay that adds all packages from this NUR repository
  # Note: vintagestory is NOT included - it requires version and hash arguments
  # Use the NixOS module or manual override instead
  default = final: prev: {
    bbport = final.callPackage ../pkgs/bbport { };
    cybergrub2077 = final.callPackage ../pkgs/cybergrub2077 { };
    nmssaveeditor = final.callPackage ../pkgs/nmssaveeditor { };
    pig = final.callPackage ../pkgs/pig { };
    rimsort-appimage = final.callPackage ../pkgs/rimsort-appimage { };
    rimsort = final.rimsort-appimage;
    scopebuddy = final.callPackage ../pkgs/scopebuddy { };
    storyforge = final.callPackage ../pkgs/storyforge { };
    wowup-cf = final.callPackage ../pkgs/wowup-cf { };
  };
}
