{
  cmake,
  qt5ct,
  wrapQtAppsHook,
  qttools,
  qtquickcontrols2,
  __internalKF5,
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
    __internalKF5.kconfig
    __internalKF5.kconfigwidgets
    __internalKF5.kiconthemes
  ];
  patches = [ ./qt5ct-shenanigans.patch ];
  cmakeFlags = [
    "-DPLUGINDIR=${placeholder "out"}/${qtbase.qtPluginPrefix}"
  ];
})
