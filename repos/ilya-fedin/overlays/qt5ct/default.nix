self: super:

let
  overrideFunc = qtAttrs: oldAttrs: rec {
    buildInputs = oldAttrs.buildInputs ++ (with qtAttrs; [
      qtquickcontrols2 kconfig kconfigwidgets kiconthemes
    ]);

    nativeBuildInputs = with super; with qtAttrs; [
      cmake wrapQtAppsHook qttools
    ];
  
    patches = [
      ./qt5ct-shenanigans.patch
    ];
  
    cmakeFlags = with qtAttrs; [
      "-DPLUGINDIR=${placeholder "out"}/${qtbase.qtPluginPrefix}"
    ];
  };
in {
  libsForQt5 = super.libsForQt5 // { 
    qt5ct = super.libsForQt5.qt5ct.overrideAttrs(overrideFunc super.libsForQt5);
  };
}
