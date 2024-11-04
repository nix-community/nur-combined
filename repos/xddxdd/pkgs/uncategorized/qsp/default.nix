{
  stdenv,
  lib,
  sources,
  cmake,
  pkg-config,
  qsp-lib,
  wxGTK32,
}:
let
  qsp-wx = wxGTK32.overrideAttrs (old: {
    inherit (sources.qsp-wx) pname version src;
    patches = (old.patches or [ ]) ++ [
      (sources.qsp.src + "/build_wx/wxPatch.diff")
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
stdenv.mkDerivation {
  inherit (sources.qsp) pname version src;

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

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "QSP is an Interactive Fiction development platform (GUI application)";
    homepage = "https://github.com/QSPFoundation/qspgui";
    license = lib.licenses.gpl2Only;
    mainProgram = "qspgui";
  };
}
