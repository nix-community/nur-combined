{ mkDerivation, lib, fetchFromGitHub, fetchsvn, fetchurl
, pkgconfig, python3, pythonPackages, cmake, ninja, dos2unix, wrapGAppsHook
, qtbase, qtimageformats, gtk3, libappindicator-gtk3, libnotify, enchant
, xdg_utils, desktop-file-utils, ffmpeg, openalSoft, lzma, lz4, xxHash
, zlib, minizip, openssl, libopus, alsaLib, libpulseaudio, rlottie-tdesktop
, range-v3, integrateWithSystem ? true
}:

with lib;

let
  ver = "1.1.2";

  # Arch patches (svn export telegram-desktop/trunk)
  archPatches = fetchsvn {
    url = "svn://svn.archlinux.org/community/telegram-desktop/trunk";
    # svn log svn://svn.archlinux.org/community/telegram-desktop/trunk
    rev = "512849";
    sha256 = "1hl7znvv6qr4cwpkj8wlplpa63i1lhk2iax7hb4l1s1a4mijx9ls";
  };

  newIcons = {
    intro_qr_plane = fetchurl {
      url = "https://raw.githubusercontent.com/telegramdesktop/tdesktop/100fed362271ada828fdaeb27e52f660a5a05d18/Telegram/Resources/icons/intro_qr_plane.png";
      sha256 = "1393092a71pcknsb527jp2hlqylqzix71kr9fxsk6pqjrfnjlgvs";
    };
  
    intro_qr_plane_2x = fetchurl {
      name = "intro_qr_plane_2x.png";
      url = "https://raw.githubusercontent.com/telegramdesktop/tdesktop/100fed362271ada828fdaeb27e52f660a5a05d18/Telegram/Resources/icons/intro_qr_plane@2x.png";
      sha256 = "1daa8yjwfi43a55b4714zm66wl7l7n2npm9xplqzl9dagnm4qas8";
    };
  
    intro_qr_plane_3x = fetchurl {
      name = "intro_qr_plane_3x.png";
      url = "https://raw.githubusercontent.com/telegramdesktop/tdesktop/100fed362271ada828fdaeb27e52f660a5a05d18/Telegram/Resources/icons/intro_qr_plane@3x.png";
      sha256 = "0rxj456g5rbikbqh8sq5qrzyxln7hd1wa4688jssjx1zvb792jhz";
    };
  };

  GYP_DEFINES = concatStringsSep "," ([
    "DESKTOP_APP_DISABLE_CRASH_REPORTS"
    "TDESKTOP_DISABLE_AUTOUPDATE"
    "TDESKTOP_DISABLE_REGISTER_CUSTOM_SCHEME"
    "TDESKTOP_DISABLE_DESKTOP_FILE_GENERATION"
  ] ++ optional integrateWithSystem "TDESKTOP_DISABLE_GTK_INTEGRATION");
in mkDerivation rec {
  pname = "kotatogram-desktop";
  version = "${ver}-1";

  src = fetchFromGitHub {
    owner = "kotatogram";
    repo = "kotatogram-desktop";
    rev = "k${ver}";
    sha256 = "0gpfhx3pbkhbkmgfsm0wjkjvaxb1aab8s7zbqad06zmxk8rdrmbb";
    fetchSubmodules = true;
  };

  patches = optionals integrateWithSystem [
    ./update-to-v1.9.3.patch
    ./cmake-rules-fix.patch
    ./fix-spellcheck.patch
    ./Use-system-font.patch
    ./system-tray-icon.patch
    ./linux-autostart.patch
    ./Use-system-font-by-default.patch
    ./Use-native-notifications-by-default.patch
  ] ++ optionals (!integrateWithSystem) [
    ./tdesktop.patch
    ./fix-glib-function.patch
    "${archPatches}/no-gtk2.patch"
  ];

  prePatch = optionalString integrateWithSystem ''
    dos2unix Telegram/build/build.bat
  '';

  postPatch = optionalString integrateWithSystem ''
    unix2dos Telegram/build/build.bat

    cp ${newIcons.intro_qr_plane} Telegram/Resources/icons/intro_qr_plane.png
    cp ${newIcons.intro_qr_plane_2x} Telegram/Resources/icons/intro_qr_plane@2x.png
    cp ${newIcons.intro_qr_plane_3x} Telegram/Resources/icons/intro_qr_plane@3x.png

    substituteInPlace Telegram/lib_spellcheck/spellcheck/platform/linux/linux_enchant.cpp \
      --replace '"libenchant-2.so.2"' '"${enchant}/lib/libenchant-2.so.2"'
  '' + optionalString (!integrateWithSystem) ''
    substituteInPlace Telegram/SourceFiles/platform/linux/linux_libs.cpp \
      --replace '"gtk-3"' '"${gtk3}/lib/libgtk-3.so"'
    substituteInPlace Telegram/SourceFiles/platform/linux/linux_libs.cpp \
      --replace '"appindicator3"' '"${libappindicator-gtk3}/lib/libappindicator3.so"'
    substituteInPlace Telegram/SourceFiles/platform/linux/linux_libnotify.cpp \
      --replace '"notify"' '"${libnotify}/lib/libnotify.so"'
  '';

  nativeBuildInputs = [ pkgconfig python3 cmake ninja ]
    ++ optional integrateWithSystem dos2unix
    ++ optionals (!integrateWithSystem) [ pythonPackages.gyp wrapGAppsHook ];

  buildInputs = [
    qtbase qtimageformats ffmpeg openalSoft lzma lz4 xxHash
    zlib minizip openssl libopus alsaLib libpulseaudio
    rlottie-tdesktop range-v3
  ] ++ optional integrateWithSystem enchant
    ++ optionals (!integrateWithSystem) [ gtk3 libappindicator-gtk3 ];

  enableParallelBuilding = true;

  # We want to run wrapProgram manually (with additional parameters) if gtk is used
  dontWrapGApps = !integrateWithSystem;
  dontWrapQtApps = !integrateWithSystem;

  qtWrapperArgs = optionals integrateWithSystem [
    "--prefix PATH : ${xdg_utils}/bin"
    "--prefix PATH : ${desktop-file-utils}/bin"
  ];

  NIX_CFLAGS_COMPILE = optionals (!integrateWithSystem) ([
    "-I${getDev libopus}/include/opus"
    "-I${getDev qtbase}/mkspecs/linux-g++"
  ] ++ concatMap (x: [
    "-I${getDev qtbase}/include/${x}"
  ]) [ "QtCore" "QtGui" "QtDBus" ] ++ concatMap (x: [
    "-I${getDev qtbase}/include/${x}/${qtbase.version}"
    "-I${getDev qtbase}/include/${x}/${qtbase.version}/${x}"
  ]) [ "QtCore" "QtGui" ]);
  CPPFLAGS = NIX_CFLAGS_COMPILE;

  cmakeFlags = optionals integrateWithSystem [
    "-DTDESKTOP_API_TEST=ON"
    "-DDESKTOP_APP_DISABLE_CRASH_REPORTS=ON"
    "-DTDESKTOP_DISABLE_REGISTER_CUSTOM_SCHEME=ON"
    "-DTDESKTOP_DISABLE_DESKTOP_FILE_GENERATION=ON"
    "-DTDESKTOP_DISABLE_GTK_INTEGRATION=ON"
  ];

  preConfigure = optionalString (!integrateWithSystem) ''
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
    mkdir -p $out/share/applications $out/share/kservices5
    install -m444 "$src/lib/xdg/kotatogramdesktop.desktop" "$out/share/applications/kotatogramdesktop.desktop"
    sed "s,/usr/bin,$out/bin,g" $src/lib/xdg/tg.protocol > $out/share/kservices5/tg.protocol
    for icon_size in 16 32 48 64 128 256 512; do
      install -Dm644 "$src/Telegram/Resources/art/icon''${icon_size}.png" "$out/share/icons/hicolor/''${icon_size}x''${icon_size}/apps/kotatogram.png"
    done
  '' + optionalString integrateWithSystem ''
    install -Dm755 bin/Telegram $out/bin/kotatogram-desktop

    mkdir -p $out/share/KotatogramDesktop/autostart
    install -m444 "${./autostart.desktop}" "$out/share/KotatogramDesktop/autostart/kotatogramdesktop.desktop"
  '' + optionalString (!integrateWithSystem) ''
    install -Dm755 Telegram $out/bin/kotatogram-desktop

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
