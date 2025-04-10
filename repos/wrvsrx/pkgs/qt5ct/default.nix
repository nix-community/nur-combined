{
  cmake,
  qt5ct,
  wrapQtAppsHook,
  qttools,
  qtquickcontrols2,
  kconfig,
  kconfigwidgets,
  kiconthemes,
  qtbase,
}:
qt5ct.overrideAttrs (old: {
  nativeBuildInputs = [
    cmake
    wrapQtAppsHook
    qttools
  ];
  buildInputs = old.buildInputs ++ [
    qtquickcontrols2
    kconfig
    kconfigwidgets
    kiconthemes
  ];
  patches = [ ./qt5ct-shenanigans.patch ];
  cmakeFlags = [
    "-DPLUGINDIR=${placeholder "out"}/${qtbase.qtPluginPrefix}"
  ];
})
