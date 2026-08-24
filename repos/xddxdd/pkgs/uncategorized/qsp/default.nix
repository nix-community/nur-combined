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
    rev = "0cac60ce0593ab7aba50f05e457282a694fca7e8";
    hash = "sha256-23Yx2DMHPQEIvY/UKLC6Dswz3rv10/7YLdb8DFB8DTY=";
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
  version = "5.9.5-unstable-2026-04-14";
  src = fetchFromGitHub {
    owner = "QSPFoundation";
    repo = "qspgui";
    rev = "0cac60ce0593ab7aba50f05e457282a694fca7e8";
    hash = "sha256-23Yx2DMHPQEIvY/UKLC6Dswz3rv10/7YLdb8DFB8DTY=";
  };
  patches = [ ./use-prebuilt-qsp-lib.patch ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ];
  buildInputs = [
    qsp-lib
    qsp-wx
  ];

  cmakeFlags = [ "-DUSE_INSTALLED_WX=ON" ];

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
