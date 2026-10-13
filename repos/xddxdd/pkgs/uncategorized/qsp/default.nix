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
    rev = "f67580195c525ef16e4ff164689d7374bdf35e8d";
    hash = "sha256-mlk/dLeAxza70QP687AlYaCN2fbZWzJz9ujjVG7/l2E=";
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
  version = "5.9.5-unstable-2026-10-13";
  src = fetchFromGitHub {
    owner = "QSPFoundation";
    repo = "qspgui";
    rev = "f67580195c525ef16e4ff164689d7374bdf35e8d";
    hash = "sha256-mlk/dLeAxza70QP687AlYaCN2fbZWzJz9ujjVG7/l2E=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  patches = [ ./use-prebuilt-qsp-lib.patch ];

  nativeBuildInputs = [
    cmake
    pkg-config
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
