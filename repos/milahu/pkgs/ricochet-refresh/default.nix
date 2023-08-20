{ lib
, stdenv
, fetchFromGitHub
, fetchFromGitLab
, makeDesktopItem
, copyDesktopItems
, pkg-config
, cmake
, qtbase
, qttools
, qtmultimedia
, qtquick1
, qtquickcontrols
, qtquickcontrols2
, openssl
, protobuf
, wrapQtAppsHook
, fmt
}:

stdenv.mkDerivation rec {

  pname = "ricochet-refresh";
  version = "3.0.16-unstable-2023-07-30";

  src = fetchFromGitHub {
    repo = "ricochet-refresh";
    # https://github.com/blueprint-freespeech/ricochet-refresh

    /*
    owner = "blueprint-freespeech";
    #rev = "v${version}-release";
    rev = "e1635d68ab08201d95c1eb823035c948836f7bd0";
    sha256 = "sha256-Qoj43Nwf81V1UVQLwT2qBaNjYA9ctv8W9UVcRF5A/pU=";
    */

    # fix cmake install paths
    # https://github.com/blueprint-freespeech/ricochet-refresh/pull/176
    owner = "milahu";
    rev = "4da56bed894628a2ed70e83c63df9c3ce5d669b9";
    sha256 = "sha256-Aa8/u5tSfd9xjPn64+Jp/LbidLbraf8ROyDd46/hESw=";

    # no. this is slow
    #fetchSubmodules = true;
  };

  # fetch git modules manually, this is faster
  # https://github.com/blueprint-freespeech/ricochet-refresh/blob/main/.gitmodules
  # https://github.com/blueprint-freespeech/ricochet-refresh/tree/main/src/extern

  # not needed
  /*
  # https://github.com/fmtlib/fmt
  fmt-version = "10.1.0";
  fmt-src = fetchFromGitHub {
    owner = "fmtlib";
    repo = "fmt";
    rev = fmt-version;
    sha256 = "sha256-t/Mcl3n2dj8UEnptQh4YgpvWrxSYN3iGPZ3LKwzlPAg=";
  };
  */

  # https://gitlab.torproject.org/tpo/core/tor
  tor-version = "0.4.8.3-rc";
  tor-src = fetchFromGitLab {
    domain = "gitlab.torproject.org";
    owner = "tpo";
    repo = "core/tor";
    rev = "tor-${tor-version}";
    hash = "sha256-A/XG8TpjiA4zq45ttuYDHb+tixZcQOp51b3Ne/m2fJY=";
  };

  /*
    rm -rf src/extern/fmt
    ln -s ${fmt-src} src/extern/fmt
  */
  postUnpack = ''
    pushd $sourceRoot
    rm -rf src/extern/tor
    ln -s ${tor-src} src/extern/tor
    popd
  '';

  desktopItem = [
    (makeDesktopItem {
      name = "ricochet-refresh";
      exec = "ricochet-refresh";
      icon = "ricochet-refresh";
      desktopName = "Ricochet Refresh";
      genericName = "Ricochet Refresh";
      categories = [ "Network" "InstantMessaging" ];
    })
  ];

  buildInputs = [
    qtbase
    qtmultimedia
    qtquick1
    qtquickcontrols
    qtquickcontrols2
    openssl
    protobuf
    fmt
  ];

  nativeBuildInputs = [
    pkg-config
    cmake
    qttools
    copyDesktopItems
    wrapQtAppsHook
  ];

  preConfigure = ''
    cd src
  '';

  cmakeFlags = [
    # TODO more?
    "-DRICOCHET_REFRESH_INSTALL_DESKTOP=ON"
    "-DUSE_SUBMODULE_FMT=OFF"
  ];

  meta = with lib; {
    description = "Private, anonymous, and metadata resistant instant messaging using Tor onion services";
    homepage = "https://www.ricochetrefresh.net";
    license = licenses.bsd3;
    platforms = platforms.all;
    maintainers = [ ];
  };
}
