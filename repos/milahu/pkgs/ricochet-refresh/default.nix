# RUN:
# nix-build -E 'with import <nixpkgs> { }; libsForQt5.callPackage ./default.nix { }'
# ./result/bin/ricochet-refresh

{ lib
, stdenv
, fetchurl
, fetchFromGitHub
, fontconfig
, freetype
, libxcb
, libxkbcommon
, xorg
, makeDesktopItem
, copyDesktopItems
, pkg-config
, qmake
, qtbase
, qttools
, qtmultimedia
, qtquick1
, qtquickcontrols
, openssl
, protobuf
, wrapQtAppsHook
}:

let
  rpath = lib.makeLibraryPath [
    fontconfig
    freetype
    libxcb
    libxkbcommon
    stdenv.cc.cc.lib
    xorg.xcbutilimage
    xorg.xcbutilkeysyms
    xorg.xcbutilrenderutil
    xorg.xcbutilwm
    xorg.libX11
    xorg.libXext
  ];

in

stdenv.mkDerivation rec { # https://nixos.org/manual/nixpkgs/stable/#qt-default-nix
#libsForQt5.mkDerivation rec { # https://discourse.nixos.org/t/wrapqtappshook-out-of-tree/5619
  pname = "ricochet-refresh";
  version = "3.0.10"; # 2021-06-27

  # stripping breaks if rpath is set to a longer value using patchelf prior
  # see: https://github.com/NixOS/patchelf/issues/10
  dontStrip = true;

  src = fetchFromGitHub {
    repo = "ricochet-refresh";
    # https://github.com/blueprint-freespeech/ricochet-refresh

    /*
    owner = "blueprint-freespeech";
    #rev = "v${version}-release";
    rev = "8cfea824db141a0850a410321ae4da5cc44fbd8f"; # required for "fetchSubmodules = true;"?
    sha256 = "0d1ln9z96ki26s8dyhaaaai88fs4mv9swvywmzq9pqzc0dwfk41p";
    */

    # some patches to fix build
    owner = "milahu";
    rev = "580a5afc723b40b93c3b5b0949addbc8d73ee182";
    sha256 = "0m45isjim9s87hlr7f7qfxkjl1csil54qjcq15v5mzlzary6qg4w";

    fetchSubmodules = true;
  };

  desktopItem = [
    (makeDesktopItem {
      name = "ricochet-refresh";
      exec = "ricochet-refresh";
      icon = "ricochet-refresh";
      desktopName = "Ricochet Refresh";
      genericName = "Ricochet Refresh";
      categories = "Network;InstantMessaging;";
    })
  ];

  buildInputs = [
    qtbase qtmultimedia qtquick1 qtquickcontrols
    openssl protobuf
  ];

  nativeBuildInputs = [
    pkg-config
    qmake
    qttools
    copyDesktopItems
    wrapQtAppsHook
  ];

  preConfigure = ''
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE $(pkg-config --cflags openssl)"

    mkdir build
    cd build
  '';

  qmakeFlags = [
    #"DEFINES+=RICOCHET_NO_PORTABLE" # By default, Ricochet Refresh will be portable, and configuration is stored in a folder named config next to the binary. Add DEFINES+=RICOCHET_NO_PORTABLE to the qmake command for a system-wide installation using platform configuration paths instead.
    "RICOCHET_REFRESH_VERSION=${version}" # used in src/tego_ui/tego_ui.pro
    "../src" # relative to build
  ];

  installPhase = ''
    cd /build/source # undo "cd build"

    mkdir -p $out/bin
    cp build/release/tego_ui/ricochet-refresh $out/bin

    # other build artifacts
    # TODO install these?
    # build/release/tst_cryptokey/tst_cryptokey
    # build/release/tst_contactidvalidator/tst_contactidvalidator
    # build/release/libtego/libtego.a
    # build/release/libtego_ui/libtego_ui.a

    mkdir -p $out/share/applications
    cp $desktopItem/share/applications"/"* $out/share/applications

    mkdir -p $out/share/pixmaps
    cp src/tego_ui/icons/ricochet_refresh.png $out/share/pixmaps
  '';

  # RCC: Error in 'translation/embedded.qrc': Cannot find file 'ricochet_en.qm'
  enableParallelBuilding = false;

  meta = with lib; {
    description = "Private, anonymous, and metadata resistant instant messaging using Tor onion services";
    homepage = "https://www.ricochetrefresh.net";
    license = licenses.bsd3;
    platforms = [ "x86_64-linux" ];
    #maintainers = teams.blueprint-freespeech.members; # FIXME attribute 'blueprint-freespeech' missing
  };
}
