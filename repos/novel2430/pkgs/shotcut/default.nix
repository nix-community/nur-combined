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
}:
let
  pname = "shotcut-bin";
  version = "25.08.16";

  _pname = "Shotcut";

  src = fetchurl {
    url = "https://github.com/mltframework/shotcut/releases/download/v${version}/shotcut-linux-x86_64-${builtins.replaceStrings [ "." ] [ "" ] version}.txz";
    hash = "sha256-elaJrcmnZLdJXQnoXi6WV8hTGgh4X7BNzmQfi8b97aM=";
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
    cp -r Shotcut.app/* $out/opt/${_pname}
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
    patchelf --replace-needed libedit.so.2 libedit.so $out/opt/Shotcut/lib/libLLVM-12.so.1
    patchelf --replace-needed libmpdec.so.2 libmpdec.so $out/opt/Shotcut/lib/python3.8/lib-dynload/_decimal.cpython-38-x86_64-linux-gnu.so
    patchelf --replace-needed libssl.so.1.1 libssl.so $out/opt/Shotcut/lib/python3.8/lib-dynload/_ssl.cpython-38-x86_64-linux-gnu.so
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
