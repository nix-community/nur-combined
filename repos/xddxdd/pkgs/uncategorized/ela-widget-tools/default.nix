{
  sources,
  lib,
  stdenv,
  cmake,
  qt6,
  ...
}:
stdenv.mkDerivation (finalAttrs: {
  inherit (sources.ela-widget-tools) pname version src;

  patches = [
    ./fix-install-path.patch
    ./qt6-qchar-fix.patch
  ];

  # Qt CMake private include path is empty, generate one ourselves
  postPatch =
    let
      includeBaseFor = component: [
        "${qt6.qtbase}/include/${component}/${qt6.qtbase.version}"
        "${qt6.qtbase}/include/${component}/${qt6.qtbase.version}/${component}"
      ];
      includePaths = builtins.concatStringsSep " " (
        lib.flatten (
          builtins.map includeBaseFor [
            "QtCore"
            "QtGui"
            "QtWidgets"
          ]
        )
      );
    in
    ''
      substituteInPlace ElaWidgetTools/CMakeLists.txt \
        --replace-fail '@QT_INCLUDE_DIRS@' "${includePaths}"
    '';

  nativeBuildInputs = [
    cmake
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
  ];

  meta = {
    mainProgram = "ElaWidgetToolsExample";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Fluent-UI For QT-Widget";
    homepage = "https://github.com/Liniyous/ElaWidgetTools";
    license = lib.licenses.mit;
  };
})
