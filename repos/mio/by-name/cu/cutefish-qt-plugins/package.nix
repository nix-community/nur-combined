{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  pkg-config,
  qt6,
  wayland,
  wayland-scanner,
  wayland-protocols,
  librsvg,
  libheif,
  libjxl,
}:

let
  cu = import ../cutefish/mk.nix { inherit lib; };
in
stdenv.mkDerivation {
  pname = "cutefish-qt-plugins";
  version = cu.version "2026-10-20";

  src = fetchFromGitHub {
    owner = "cutefishos";
    repo = "qt-plugins";
    rev = "7e1a132d26aae471832179f765c7c5d28d62bc4a";
    hash = "sha256-NymabMQZIYPYcVURo8NiROIQE1i8f3Q89X96tYGTv3w=";
  };

  patches = [ ../cutefish/patches/qt-handle-theme-change.patch ];

  postPatch = ''
    substituteInPlace platformtheme/CMakeLists.txt \
      --replace-fail 'LIBRARY DESTINATION "''${QT_PLUGINS_DIR}/platformthemes"' \
        'LIBRARY DESTINATION "''${CMAKE_INSTALL_PREFIX}/${qt6.qtbase.qtPluginPrefix}/platformthemes"'
    substituteInPlace imageformat/CMakeLists.txt imageformat/heif/CMakeLists.txt imageformat/jxl/CMakeLists.txt \
      --replace-fail 'DESTINATION ''${CMAKE_INSTALL_QTPLUGINDIR}/imageformats/' \
        'DESTINATION ''${CMAKE_INSTALL_PREFIX}/${qt6.qtbase.qtPluginPrefix}/imageformats/'
  '';

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    qt6.wrapQtAppsHook
    wayland-scanner
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtdeclarative
    wayland
    wayland-protocols
    librsvg
    libheif
    libjxl
  ];

  # The platform theme loads libcutefish-qt-scrolling-quick by name.
  dontWrapQtApps = true;
  cmakeFlags = cu.cmakeFlags;

  postFixup = ''
    for plugin in "$out/${qt6.qtbase.qtPluginPrefix}/platformthemes/"*.so; do
      patchelf --add-rpath "$out/lib" "$plugin"
    done
  '';

  meta = {
    inherit (cu) homepage platforms;
    description = "Qt 6 platform theme, scrolling and image plugins for the Cutefish desktop";
    license = lib.licenses.bsd3;
  };
}
