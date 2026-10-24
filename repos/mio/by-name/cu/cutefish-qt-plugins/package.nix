{
  mkCutefishDerivation,
  qt6,
  wayland,
  wayland-scanner,
  wayland-protocols,
  librsvg,
  libheif,
  libjxl,
}:

mkCutefishDerivation {
  pname = "cutefish-qt-plugins";
  withGettext = false;

  patches = [ ./qt-handle-theme-change.patch ];

  postPatch = ''
    substituteInPlace platformtheme/CMakeLists.txt \
      --replace-fail 'LIBRARY DESTINATION "''${QT_PLUGINS_DIR}/platformthemes"' \
        'LIBRARY DESTINATION "''${CMAKE_INSTALL_PREFIX}/${qt6.qtbase.qtPluginPrefix}/platformthemes"'
    substituteInPlace imageformat/CMakeLists.txt imageformat/heif/CMakeLists.txt imageformat/jxl/CMakeLists.txt \
      --replace-fail 'DESTINATION ''${CMAKE_INSTALL_QTPLUGINDIR}/imageformats/' \
        'DESTINATION ''${CMAKE_INSTALL_PREFIX}/${qt6.qtbase.qtPluginPrefix}/imageformats/'
  '';

  # qtpaths6 is used at configure time, so Qt has to be a native input
  # once strictDeps splits build tools from libraries.
  extraNativeBuildInputs = [
    qt6.qtbase
    qt6.wrapQtAppsHook
    wayland-scanner
  ];

  extraBuildInputs = [
    qt6.qtbase
    qt6.qtdeclarative
    wayland
    wayland-scanner
    wayland-protocols
    librsvg
    libheif
    libjxl
  ];

  # The platform theme loads libcutefish-qt-scrolling-quick by name.
  dontWrapQtApps = true;

  postFixup = ''
    for plugin in "$out/${qt6.qtbase.qtPluginPrefix}/platformthemes/"*.so; do
      patchelf --add-rpath "$out/lib" "$plugin"
    done
  '';

  meta = {
    description = "Qt 6 platform theme, scrolling and image plugins for the Cutefish desktop";
  };
}
