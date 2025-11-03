{ lib, stdenv, makeWrapper, autoPatchelfHook, copyDesktopItems, fetchurl, makeDesktopItem
, SDL2
, frei0r
, ladspaPlugins
, gettext
, mlt
, jack1
, fftw
, qt6
, ffmpeg
, gnutar
, libedit
, sox
, mpdecimal
, libxcrypt-legacy
, readline
, ncurses
, openssl
, libinput
, lame
, libvpx
, x264
, movit
, opencv
, libxkbcommon
, e2fsprogs
, libtiff
, libnsl
, libtirpc
}:
let
  pname = "shotcut-bin";
  version = "25.11.2";

  _pname = "Shotcut";

  src = fetchurl {
    url = "https://github.com/mltframework/shotcut/releases/download/v25.10.31/shotcut-linux-x86_64-${version}.txz";
    hash = "sha256-2dbGvD61Gq7Fn9GF/HNMWrQ9pdJnMSlLhBme2/LTAwo=";
  };

  libs = with qt6; [
    SDL2
    frei0r
    ladspaPlugins
    gettext
    mlt
    fftw
    jack1
    ffmpeg
    libedit
    sox
    mpdecimal
    libxcrypt-legacy
    readline
    ncurses
    openssl
    libinput
    frei0r
    libvpx
    x264
    lame
    movit
    opencv
    libxkbcommon
    e2fsprogs
    libtiff
    libnsl
    libtirpc
    # Qt6
    qtbase
    qttools
    qtmultimedia
    qtcharts
    qtwayland
    qtvirtualkeyboard
    qtquicktimeline
    qtlottie
    qtscxml
    qtdeclarative
    qtimageformats
    qtmultimedia
    qttranslations
  ];

in
stdenv.mkDerivation{
  inherit pname version src;
  unpackCmd = "tar -xf $src";

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    copyDesktopItems
    gnutar
  ];

  buildInputs = libs;

  dontWrapQtApps = true;

  installPhase =''
    runHook preInstall

    mkdir -p $out/opt/${_pname}
    cp -r ./* $out/opt/${_pname}
    rm $out/opt/Shotcut/lib/qt6/egldeviceintegrations/libqeglfs-kms-integration.so
    # Icon
    mkdir -p $out/share/icons
    mv $out/opt/${_pname}/share/icons $out/share/icons
    mkdir -p $out/share/applications
    mv $out/opt/${_pname}/share/applications/org.mattbas.Glaxnimate.desktop $out/share/applications/org.mattbas.Glaxnimate.desktop
    # wrapper
    mkdir -p $out/bin
    makeWrapper $out/opt/${_pname}/shotcut $out/bin/shotcut \
      --set XKB_CONFIG_ROOT "/run/current-system/sw/share/X11/xkb" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath libs}
    makeWrapper $out/opt/${_pname}/glaxnimate $out/bin/glaxnimate \
      --set XKB_CONFIG_ROOT "/run/current-system/sw/share/X11/xkb" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath libs}

    runHook postInstall
  '';
  preFixup = ''
    patchelf --replace-needed libedit.so.2 libedit.so $out/opt/Shotcut/lib/libLLVM-15.so.1
    patchelf --replace-needed libtiff.so.5 libtiff.so $out/opt/Shotcut/bin/cwebp
    patchelf --replace-needed libtiff.so.5 libtiff.so $out/opt/Shotcut/bin/img2webp
    patchelf --replace-needed libmpdec.so.3 libmpdec.so $out/opt/Shotcut/lib/python3.10/lib-dynload/_decimal.cpython-310-x86_64-linux-gnu.so
    patchelf --replace-needed libnsl.so.2 libnsl.so $out/opt/Shotcut/lib/python3.10/lib-dynload/nis.cpython-310-x86_64-linux-gnu.so
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "${_pname}";
      desktopName = "${_pname}";
      type = "Application";
      exec = "shotcut %F";
      terminal = false;
      icon = "org.shotcut.Shotcut";
      comment = "Shotcut is a free, open source, cross-platform video editor.";
      startupWMClass = "Shotcut";
      categories = [ "AudioVideo" "Video" "AudioVideoEditing" ];
      startupNotify = true;
      keywords = [
        "video" "audio" "editing" "suite" "mlt" "4k" 
        "video4linux" "blackmagic" "decklink"
      ];
    })
  ];

  meta = {
    description = "Free, open source, cross-platform video editor";
    longDescription = ''
      An official binary for Shotcut, which includes all the
      dependencies pinned to specific versions, is provided on
      http://shotcut.org.

      If you encounter problems with this version, please contact the
      nixpkgs maintainer(s). If you wish to report any bugs upstream,
      please use the official build from shotcut.org instead.
    '';
    homepage = "https://shotcut.org";
    license = lib.licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
  };
}
