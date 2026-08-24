{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,
  cmake,
  qt6,
  ...
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "ela-widget-tools";
  version = "0-unstable-2026-08-14";
  src = fetchFromGitHub {
    owner = "Liniyous";
    repo = "ElaWidgetTools";
    rev = "190c02e5bccb3614750a986945934a77ba7d90e7";
    hash = "sha256-S34SIckwn+AemcjtJ2rAueqAWLQFXwuYWSD7Kmq+KeE=";
  };
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

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };
  meta = {
    mainProgram = "ElaWidgetToolsExample";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Fluent-UI For QT-Widget";
    homepage = "https://github.com/Liniyous/ElaWidgetTools";
    license = lib.licenses.mit;
  };
})
