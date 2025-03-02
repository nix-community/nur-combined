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
  version = "unstable-2025-01-30";

  src = fetchFromGitHub {
    owner = "Nheko-Reborn";
    repo = "nheko";
    rev = "8a5a00493682ee677d2a239717bde19cb30ec1a1";
    hash = "sha256-jYh3yYd/lUadXLIiKW8rx6+3hLsVBuN31LB1E98suHg=";
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
