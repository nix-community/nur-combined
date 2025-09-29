pkgs: with pkgs; with kdePackages; with qt6Packages; qt6ct.overrideAttrs(oldAttrs: rec {
  buildInputs = oldAttrs.buildInputs ++ ([
    qtdeclarative kconfig kcolorscheme kiconthemes
  ]);

  patches = [
    ./qt6ct-shenanigans.patch
  ];
})
