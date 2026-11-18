{
  fetchFromGitHub,
  lib,
  unstableGitUpdater,
  stdenv,
  cmake,
  qt6,
  ...
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "ela-widget-tools";
  version = "0-unstable-2026-11-18";
  src = fetchFromGitHub {
    owner = "Liniyous";
    repo = "ElaWidgetTools";
    rev = "18a9bdad86af2c2538dac7d76b0f185e610cd991";
    hash = "sha256-Tczr3v13+dVuIbvfyyhvCrfz1V4yDLP8/2lNCYcbQBA=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  patches = [
    ./fix-install-path.patch
    ./qt6-qchar-fix.patch
    ./qt6-missing-includes.patch
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

  passthru.updateScript = unstableGitUpdater {
    url = "https://github.com/Liniyous/ElaWidgetTools";
    hardcodeZeroVersion = true;
  };
  meta = {
    mainProgram = "ElaWidgetToolsExample";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Fluent-UI For QT-Widget";
    homepage = "https://github.com/Liniyous/ElaWidgetTools";
    license = lib.licenses.mit;
  };
})
