with import ./default.nix;
builtins.attrValues {
  inherit (pkgs)
    stremio
    minecraft
    discord
  ;
  inherit (pkgs.idea)
    idea-ultimate # it sourcebuild the JDK
  ;
  inherit (pkgs.python3Packages)
    scikitlearn
  ;
  inherit (pkgs.wineApps)
    wine7zip
    pinball
  ;
  polybar = pkgs.callPackage ./modules/polybar/customPolybar.nix {};
  inherit (builtins.mapAttrs (k: v: v.config.system.build.toplevel) nixosConfigurations)
    acer-nix
    vps
  ;
  inherit (builtins.mapAttrs (k: v: v.activationPackage) homeConfigurations)
    main
  ;
}
