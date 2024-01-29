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
, tor
}:

stdenv.mkDerivation rec {

  pname = "ricochet-refresh";
  version = "3.0.19";

  src = fetchFromGitHub {
    repo = "ricochet-refresh";
    # https://github.com/blueprint-freespeech/ricochet-refresh
    owner = "blueprint-freespeech";
    # fix: undefined reference to symbol
    # https://github.com/blueprint-freespeech/ricochet-refresh/pull/182
    rev = "c785fbc9c705a3be8e8910257744423da0dd05b5";
    sha256 = "sha256-fF+nZ9OQzB+QVt+5G9Ho8bIOLl32KtCv89f1BSxO0GQ=";
    # no. this is slow
    #fetchSubmodules = true;
  };

  # fetch git modules manually, this is faster
  # https://github.com/blueprint-freespeech/ricochet-refresh/blob/main/.gitmodules
  # https://github.com/blueprint-freespeech/ricochet-refresh/tree/main/src/extern

  postUnpack = ''
    pushd $sourceRoot
    echo unpacking ${tor.src}
    rm -rf src/extern/tor
    mkdir src/extern/tor
    tar -x -f ${tor.src} -C src/extern/tor --strip-components=1
    popd
  '';

  postPatch = ''
    # fix: error: Cannot format an argument
    # https://github.com/blueprint-freespeech/ricochet-refresh/issues/180
    substituteInPlace src/libtego/source/protocol/FileChannel.cpp \
      --replace \
        'fmt::format("Unknown FileChannel::direction()", direction)' \
        '"Unknown FileChannel::direction()"' \
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
