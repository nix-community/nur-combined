{ mkDerivation, lib, fetchFromGitHub, fetchsvn, fetchpatch
, pkgconfig, pythonPackages, cmake, ninja, wrapGAppsHook, qtbase
, qtimageformats, gtk3, libappindicator-gtk3, libnotify, xdg_utils
, desktop-file-utils, ffmpeg_4, openalSoft, lzma, lz4, xxHash, zlib
, minizip, openssl, libtgvoip, rlottie-tdesktop, range-v3
, integrateWithSystem ? true, adaptiveBaloons ? true
}:

with lib;

let
  # Arch patches (svn export telegram-desktop/trunk)
  archPatches = fetchsvn {
    url = "svn://svn.archlinux.org/community/telegram-desktop/trunk";
    # svn log svn://svn.archlinux.org/community/telegram-desktop/trunk
    rev = "512849";
    sha256 = "1hl7znvv6qr4cwpkj8wlplpa63i1lhk2iax7hb4l1s1a4mijx9ls";
  };

  animatedStickersPatch = fetchpatch {
    url = "https://github.com/kotatogram/kotatogram-desktop/commit/a196b0aba723de85ee573594d9ad420412b6391a.patch";
    sha256 = "1mzfvcgj42r05k27423hbkvgg0gjrm3xv9hvadfqaq1ys46bpqi0";
  };

  GYP_DEFINES = concatStringsSep "," ([
    "DESKTOP_APP_DISABLE_CRASH_REPORTS"
    "TDESKTOP_DISABLE_AUTOUPDATE"
    "TDESKTOP_DISABLE_REGISTER_CUSTOM_SCHEME"
    "TDESKTOP_DISABLE_DESKTOP_FILE_GENERATION"
  ] ++ optional integrateWithSystem "TDESKTOP_DISABLE_GTK_INTEGRATION");
in mkDerivation rec {
  pname = "kotatogram-desktop";
  version = "1.1.1-3";

  src = fetchFromGitHub {
    owner = "kotatogram";
    repo = "kotatogram-desktop";
    rev = "k${version}";
    sha256 = "156r229dpxnyaxxgp1dr4vz8jla5p7r0dydhgdgk2yx1p11z6m3w";
    fetchSubmodules = true;
  };

  patches = [
    ./tdesktop.patch
    animatedStickersPatch
  ] ++ optionals integrateWithSystem [
    ./fix-unneeded-private-header.patch
    ./Use-system-wide-font.patch
    ./Use-system-wide-font-families.patch
    ./Parse-Semibold-Fontnames.patch
    ./QtDBus-Notifications-Implementation.patch
    ./system-tray-icon.patch
    ./linux-autostart.patch
    ./Use-native-notifications-by-default.patch
  ] ++ optionals (!integrateWithSystem) [
    ./fix-glib-function.patch
    "${archPatches}/no-gtk2.patch"
  ] ++ optional adaptiveBaloons ./baloons-follows-text-width-on-adaptive-layout.patch;

  postPatch = optionalString (!integrateWithSystem) ''
    substituteInPlace Telegram/SourceFiles/platform/linux/linux_libs.cpp \
      --replace '"gtk-3"' '"${gtk3}/lib/libgtk-3.so"'
    substituteInPlace Telegram/SourceFiles/platform/linux/linux_libs.cpp \
      --replace '"appindicator3"' '"${libappindicator-gtk3}/lib/libappindicator3.so"'
    substituteInPlace Telegram/SourceFiles/platform/linux/linux_libnotify.cpp \
      --replace '"notify"' '"${libnotify}/lib/libnotify.so"'
  '';

  nativeBuildInputs = [ pkgconfig pythonPackages.gyp cmake ninja ]
    ++ optional (!integrateWithSystem) wrapGAppsHook;

  buildInputs = [
    qtbase qtimageformats ffmpeg_4 openalSoft lzma lz4 xxHash
    zlib minizip openssl libtgvoip rlottie-tdesktop range-v3
  ] ++ optionals (!integrateWithSystem) [ gtk3 libappindicator-gtk3 ];

  enableParallelBuilding = true;

  # We want to run wrapProgram manually (with additional parameters) if gtk is used
  dontWrapGApps = !integrateWithSystem;
  dontWrapQtApps = !integrateWithSystem;

  qtWrapperArgs = optionals integrateWithSystem [
    "--prefix PATH : ${xdg_utils}/bin"
    "--prefix PATH : ${desktop-file-utils}/bin"
  ];

  NIX_CFLAGS_COMPILE = [
    "-I${getDev libtgvoip}/include/tgvoip"
  ] ++ optional (!integrateWithSystem) "-I${getDev qtbase}/mkspecs/linux-g++"
  ++ concatMap (x: [
    "-I${getDev qtbase}/include/${x}"
  ]) [ "QtCore" "QtGui" "QtDBus" ] ++ concatMap (x: [
    "-I${getDev qtbase}/include/${x}/${qtbase.version}"
    "-I${getDev qtbase}/include/${x}/${qtbase.version}/${x}"
  ]) [ "QtCore" "QtGui" ];
  CPPFLAGS = NIX_CFLAGS_COMPILE;

  preConfigure = ''
    gyp \
      -Dapi_id=17349 \
      -Dapi_hash=344583e45741c457fe1862106095a5eb \
      -Dbuild_defines=${GYP_DEFINES} \
      -Dlottie_use_cache=1 \
      -Gconfig=Release \
      --depth=Telegram/gyp \
      --generator-output=../.. \
      -Goutput_dir=out \
      --format=cmake \
      Telegram/gyp/Telegram.gyp

    cd out/Release

    NUM=$((`wc -l < CMakeLists.txt` - 2))
    sed -i "$NUM r ${./CMakeLists.inj}" CMakeLists.txt
  '';

  installPhase = ''
    install -Dm755 Telegram $out/bin/kotatogram-desktop

    mkdir -p $out/share/applications $out/share/kservices5
    install -m444 "$src/lib/xdg/kotatogramdesktop.desktop" "$out/share/applications/kotatogramdesktop.desktop"
    sed "s,/usr/bin,$out/bin,g" $src/lib/xdg/tg.protocol > $out/share/kservices5/tg.protocol
    for icon_size in 16 32 48 64 128 256 512; do
      install -Dm644 "../../../Telegram/Resources/art/icon''${icon_size}.png" "$out/share/icons/hicolor/''${icon_size}x''${icon_size}/apps/kotatogram.png"
    done
  '' + optionalString integrateWithSystem ''
    mkdir -p $out/share/KotatogramDesktop/autostart
    install -m444 "${./autostart.desktop}" "$out/share/KotatogramDesktop/autostart/kotatogramdesktop.desktop"
  '';

  postFixup = optionalString (!integrateWithSystem) ''
    # This is necessary to run Kotatogram in a pure environment.
    # We also use gappsWrapperArgs from wrapGAppsHook.
    wrapProgram $out/bin/kotatogram-desktop \
      "''${gappsWrapperArgs[@]}" \
      "''${qtWrapperArgs[@]}" \
      --prefix PATH : ${xdg_utils}/bin
  '';

  meta = {
    description = "Kotatogram – experimental Telegram Desktop fork";
    longDescription = ''
      Unofficial desktop client for the Telegram messenger, based on Telegram Desktop.
      It contains some useful (or purely cosmetic) features, but they could be unstable. A detailed list is available here: https://kotatogram.github.io/changes
    '';
    license = licenses.gpl3;
    platforms = platforms.linux;
    homepage = https://kotatogram.github.io;
  };
}
