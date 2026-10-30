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
    rev = "3d9050f9974ec48eae96760900c847b0efa0cfe5";
    hash = "sha256-/Z+MoDZaKT5IyHJrrYENRl4uHmCoNN13Di0nYDPwEYs=";
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
  version = "5.9.5-unstable-2026-10-15";
  src = fetchFromGitHub {
    owner = "QSPFoundation";
    repo = "qspgui";
    rev = "3d9050f9974ec48eae96760900c847b0efa0cfe5";
    hash = "sha256-/Z+MoDZaKT5IyHJrrYENRl4uHmCoNN13Di0nYDPwEYs=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  patches = [
    ./use-prebuilt-qsp-lib.patch
    ./qsp-init-seed.patch
  ];

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
