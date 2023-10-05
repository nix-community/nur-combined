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
, voipSupport ? true
, gst_all_1
, libnice
}:

stdenv.mkDerivation {
  pname = "nheko";
  version = "unstable-2023-10-04";

  src = fetchFromGitHub {
    owner = "Nheko-Reborn";
    repo = "nheko";
    rev = "f00b246af1936e32438a1b08c1b0f6e95a0ba56e";
    hash = "sha256-Q0AhNXvDEkm9B5gxhb3WhG/hZiv//Leq6Snh6Xu3/pc=";
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
