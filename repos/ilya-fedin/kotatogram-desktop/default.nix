{ mkDerivation, lib, fetchFromGitHub, fetchsvn, fetchpatch
, pkgconfig, pythonPackages, cmake, ninja, gcc9, qtbase
, qtimageformats, ffmpeg_4, openalSoft, lzma, lz4, zlib
, minizip, openssl, libtgvoip, rlottie-tdesktop, range-v3
}:

with lib;

mkDerivation rec {
  pname = "kotatogram-desktop";
  version = "1.1.1-1";

  src = fetchFromGitHub {
    owner = "kotatogram";
    repo = "kotatogram-desktop";
    rev = "k${version}";
    sha256 = "156r229dpxnyaxxgp1dr4vz8jla5p7r0dydhgdgk2yx1p11z6m3w";
    fetchSubmodules = true;
  };

  animatedStickersPatch = fetchpatch {
    url = "https://github.com/kotatogram/kotatogram-desktop/commit/a196b0aba723de85ee573594d9ad420412b6391a.patch";
    sha256 = "1mzfvcgj42r05k27423hbkvgg0gjrm3xv9hvadfqaq1ys46bpqi0";
  };

  patches = [
    ./tdesktop.patch
    ./Use-system-wide-font.patch
    ./Parse-Semibold-Fontnames.patch
    ./QtDBus-Notifications-Implementation.patch
    ./system-tray-icon.patch
    ./linux-autostart.patch
    ./Use-native-notifications-by-default.patch
    animatedStickersPatch
  ];

  nativeBuildInputs = [ pkgconfig pythonPackages.gyp cmake ninja gcc9 ];

  buildInputs = [
    qtbase qtimageformats ffmpeg_4 openalSoft lzma
    lz4 zlib minizip openssl libtgvoip rlottie-tdesktop range-v3
  ];

  enableParallelBuilding = true;

  GYP_DEFINES = concatStringsSep "," [
    "DESKTOP_APP_DISABLE_CRASH_REPORTS"
    "TDESKTOP_DISABLE_AUTOUPDATE"
    "TDESKTOP_DISABLE_REGISTER_CUSTOM_SCHEME"
    "TDESKTOP_DISABLE_DESKTOP_FILE_GENERATION"
    "TDESKTOP_DISABLE_GTK_INTEGRATION"
  ];

  NIX_CFLAGS_COMPILE = [
    "-I${getDev libtgvoip}/include/tgvoip"
    # See Telegram/gyp/qt.gypi
    "-I${getDev qtbase}/mkspecs/linux-g++"
  ] ++ concatMap (x: [
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
    install -m444 "$src/lib/xdg/kotatogramdesktop.desktop" "$out/share/applications/kotatogram-desktop.desktop"
    sed "s,/usr/bin,$out/bin,g" $src/lib/xdg/tg.protocol > $out/share/kservices5/tg.protocol
    for icon_size in 16 32 48 64 128 256 512; do
      install -Dm644 "../../../Telegram/Resources/art/icon''${icon_size}.png" "$out/share/icons/hicolor/''${icon_size}x''${icon_size}/apps/kotatogram.png"
    done
  '';

  meta = {
    description = "Kotatogram – experimental Telegram Desktop fork";
    longDescription = ''
      Unofficial desktop client for the Telegram messenger, based on Telegram Desktop.
    '';
    license = licenses.gpl3;
    platforms = platforms.linux;
    homepage = https://github.com/kotatogram/kotatogram-desktop;
  };
}
