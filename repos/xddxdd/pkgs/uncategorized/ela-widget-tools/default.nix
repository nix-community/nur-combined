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
  version = "0-unstable-2026-10-09";
  src = fetchFromGitHub {
    owner = "Liniyous";
    repo = "ElaWidgetTools";
    rev = "aae58f5d0d98e05eabe10c263aa7da5f2491d702";
    hash = "sha256-G3Qp4aOM3lhsyJfaybcfSrfW68UzK3zBCHURsQL/ljM=";
  };
  __structuredAttrs = true;
  strictDeps = true;
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
