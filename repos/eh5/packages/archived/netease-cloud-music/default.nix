{
  lib,
  stdenv,
  runCommandCC,
  pkg-config,
  fetchurl,
  autoPatchelfHook,
  dpkg,
  libsForQt5,
  libudev0-shim,
  qcef,
  taglib,
  vlc,
  xorg,
}:
let
  inherit (libsForQt5) qt5 wrapQtAppsHook;
  preloadPatch =
    runCommandCC "n-c-m-patch"
      {
        nativeBuildInputs = [ pkg-config ];
        buildInputs = [ vlc ];
      }
      ''
        mkdir -p $out
        $CC -O2 -fPIC -shared \
         $(pkg-config --cflags-only-I libvlc vlc-plugin) \
         -o $out/n-c-m-patch.so ${./preload_patch.c}
      '';
in
stdenv.mkDerivation {
  pname = "netease-cloud-music";
  version = "1.2.0";
  src = fetchurl {
    url = "https://d1.music.126.net/dmusic/netease-cloud-music_1.2.0_amd64_deepin_stable_20190424.deb";
    sha256 = "sha256-AZrLj9dh7uM6OFamyrpfKUlanfjLPTSrA22fUyOW6EE=";
    curlOpts = "-A 'Mozilla/5.0'";
  };
  unpackCmd = "${dpkg}/bin/dpkg -x $src source";
  sourceRoot = "source/usr";
  nativeBuildInputs = [
    wrapQtAppsHook
    autoPatchelfHook
  ];
  buildInputs = [
    libudev0-shim
    # qcef will have other libs that n-c-m needs
    qcef
    qt5.qtbase
    taglib
    vlc
  ];

  installPhase = ''
    mkdir -p $out/bin $out/share
    install -Dm755 bin/netease-cloud-music $out/bin
    cp -r share/* $out/share
  '';

  qtWrapperArgs = [
    # see https://rs.io/fix-fatal-udev-loader-cc-nixos/
    "--prefix LD_LIBRARY_PATH : ${libudev0-shim}/lib"
    "--prefix LD_PRELOAD : ${preloadPatch}/n-c-m-patch.so"
    # workaround for non-NixOS
    "--suffix XCURSOR_PATH : ~/.local/share/icons:~/.icons:/usr/share/icons:/usr/share/pixmaps"
    "--set QT_XKB_CONFIG_ROOT ${xorg.xkeyboardconfig}/share/X11/xkb"
  ];

  meta = {
    description = "Netease cloud music player.";
    homepage = "https://music.163.com";
    platforms = [ "x86_64-linux" ];
    license = lib.licenses.unfreeRedistributable;
  };
}
