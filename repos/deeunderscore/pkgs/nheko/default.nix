# This file is a modified version of nixpkgs/pkgs/applications/networking/instant-messengers/nheko/default.nix (copied at 2e896fce)

{ lib
, stdenv
, fetchFromGitHub
, cmake
, wrapQtAppsHook
, asciidoctor
, qtbase
, qttools
, qtsvg
, qtmultimedia
, qtimageformats
, qtkeychain
, cmark
, coeurl
, curl
, libevent
, lmdb
, lmdbxx
, mtxclient
, nlohmann_json
, olm
, pkg-config
, re2
, spdlog
, httplib
, kdsingleapplication
, voipSupport ? true
, gst_all_1
, libnice
}:

stdenv.mkDerivation {
  pname = "nheko";
  version = "0.12.0-unstable-2025-05-25";

  src = fetchFromGitHub {
    owner = "Nheko-Reborn";
    repo = "nheko";
    rev = "978174af774f99bb70df2ad5307ae161be6190ff";
    hash = "sha256-uI5tBldTT7NrhX/+t9/R/4sGlHG/3EjBryeZpojgxTc=";
  };

  nativeBuildInputs = [
    lmdbxx
    cmake
    pkg-config
    asciidoctor
    wrapQtAppsHook
  ];

  buildInputs = [
    qtbase
    qttools
    qtsvg
    qtmultimedia
    qtimageformats
    qtkeychain
    cmark
    coeurl
    curl
    libevent
    lmdb
    mtxclient
    nlohmann_json
    olm
    re2
    spdlog
    httplib
    kdsingleapplication
  ] ++ lib.optionals voipSupport (with gst_all_1; [
    gstreamer
    gst-plugins-base
    (gst-plugins-good.override { qt5Support = true; })
    gst-plugins-bad
    libnice
  ]);

  LC_ALL = lib.optionalString (!stdenv.isDarwin) "C.UTF-8";

  cmakeFlags = [
    "-DCOMPILE_QML=ON" # see https://github.com/Nheko-Reborn/nheko/issues/389
    "-DCMAKE_BUILD_TYPE=Release"
    "-DBUILD_SHARED_LIBS=OFF"
  ];


  preFixup = lib.optionalString voipSupport ''
    # add gstreamer plugins path to the wrapper
    qtWrapperArgs+=(--prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "$GST_PLUGIN_SYSTEM_PATH_1_0")
  '';

  meta = with lib; {
    description = "Desktop client for the Matrix protocol";
    homepage = "https://github.com/Nheko-Reborn/nheko";
    platforms = platforms.all;
    license = licenses.gpl3Plus;
  };
}
