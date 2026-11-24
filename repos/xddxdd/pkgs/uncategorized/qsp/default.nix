{
  fetchFromGitHub,
  stdenv,
  lib,
  cmake,
  pkg-config,
  qsp-lib,
  wxGTK32,
}:
let
  qspSrc = fetchFromGitHub {
    owner = "QSPFoundation";
    repo = "qspgui";
    rev = "9a54c047cec12b8eaacf4a87d4e57c75e5068173";
    hash = "sha256-SuGHOpnDumojsWlrsF+RJxBt7mzgJ2j44cf1nqBrFaY=";
  };

  qsp-wx = wxGTK32.overrideAttrs (old: {
    pname = "qsp-wx";
    version = "5d63efc902e8b29c05ee492ff0c732a929f7b096";
    src = fetchFromGitHub {
      owner = "wxWidgets";
      repo = "wxWidgets";
      rev = "5d63efc902e8b29c05ee492ff0c732a929f7b096";
      fetchSubmodules = true;
      hash = "sha256-VIVancRxrRTOVS6T1TX5NCAX+O1G/ZqIRVIyLlY+mys=";
    };
    patches = (old.patches or [ ]) ++ [
      (qspSrc + "/build_wx/wxPatch.diff")
    ];

    configureFlags = builtins.filter (
      v:
      !builtins.elem v [
        "--enable-compat28"
        "--disable-compat28"
        "--enable-unicode"
      ]
    ) old.configureFlags;
  });
in
stdenv.mkDerivation (finalAttrs: {
  pname = "qsp";
  version = "5.9.5-unstable-2026-11-23";
  src = fetchFromGitHub {
    owner = "QSPFoundation";
    repo = "qspgui";
    rev = "9a54c047cec12b8eaacf4a87d4e57c75e5068173";
    hash = "sha256-SuGHOpnDumojsWlrsF+RJxBt7mzgJ2j44cf1nqBrFaY=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  patches = [ ./use-prebuilt-qsp-lib.patch ];

  nativeBuildInputs = [
    cmake
    pkg-config
    qsp-wx
  ];
  buildInputs = [
    qsp-lib
    qsp-wx
  ];

  cmakeFlags = [ (lib.cmakeBool "USE_INSTALLED_WX" true) ];

  passthru = {
    inherit qsp-lib qsp-wx;
  };

  passthru.updateScript = [ (toString ./update.sh) ];
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Interactive Fiction development platform (GUI application)";
    homepage = "https://github.com/QSPFoundation/qspgui";
    license = lib.licenses.gpl2Only;
    mainProgram = "qspgui";
  };
})
