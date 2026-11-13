{
  lib,
  appimageTools,
  fetchurl,
  ffmpeg,
  graphite2,
  kdePackages,
  libbsd,
  libdatrie,
  libepoxy,
  libffi,
  libjpeg8,
  libmd,
  libpng,
  libselinux,
  lz4,
  pcre,
  pcre2,
  pulseaudio,
  runCommandLocal,
  wl-clipboard,
  xcbutilcursor,
  xclip,
  xdotool,
  ydotool,
  zstd,
}: let
  # The wrapper executable is named after pname, and the command must be `dikte`.
  pname = "dikte";
  version = "2.4.0";

  src = fetchurl {
    url = "https://github.com/yusufipk/dikte/releases/download/v${version}/Dikte-${version}-x86_64.AppImage";
    hash = "sha256-2tXhP1nM3PpOCSpn2hVAJhtlh1y0OU0wQKsWHBJCUzo=";
  };

  # Extract the AppImage contents so we can lift out the .desktop entry and
  # icon.
  appimageContents = appimageTools.extract {inherit pname version src;};

  # The bundled glib was linked against Debian's pcre3, which names its soname
  # libpcre.so.3. nixpkgs ships the same library as libpcre.so.1 and exports
  # every symbol glib imports from it, so only the file name differs.
  pcreSonameCompat = runCommandLocal "pcre-soname-compat" {} ''
    mkdir -p $out/lib
    ln -s ${lib.getLib pcre}/lib/libpcre.so.1 $out/lib/libpcre.so.3
  '';
in
  appimageTools.wrapType2 {
    inherit pname version src;

    extraInstallCommands = ''
      install -Dm644 "${appimageContents}/dikte.desktop" \
        "$out/share/applications/dikte.desktop"

      install -Dm644 "${appimageContents}/dikte.png" \
        "$out/share/icons/hicolor/256x256/apps/dikte.png"
    '';

    # The bundle is a PyInstaller build with its own Python and Qt6, but it
    # leaves libxcb-cursor to the host, and the libraries its bundled GTK3,
    # systemd and Qt6 depend on (libffi, zstd, lz4, png, pcre2, selinux, ...)
    # are not found inside the FHS environment. The programs below are the ones
    # Dikte starts as subprocesses: audio capture and conversion, clipboard
    # access, keystroke injection for auto-paste, and the KDE shortcut helper.
    extraPkgs = pkgs: [
      ffmpeg
      graphite2
      kdePackages.kconfig
      libbsd
      libdatrie
      libepoxy
      libffi
      libjpeg8
      libmd
      libpng
      libselinux
      lz4
      pcre2
      pcreSonameCompat
      pulseaudio
      wl-clipboard
      xcbutilcursor
      xclip
      xdotool
      ydotool
      zstd
    ];

    meta = with lib; {
      description = "Local voice dictation with whisper.cpp, built for Turkish and terminal agents";
      homepage = "https://github.com/yusufipk/dikte";
      license = licenses.gpl3Only;
      sourceProvenance = with sourceTypes; [binaryNativeCode];
      platforms = ["x86_64-linux"];
      mainProgram = "dikte";
      maintainers = ["Ahmet Çetinkaya <contact@ahmetcetinkaya.me>"];
    };

    # Dikte uses APPIMAGE both for its saved desktop entries and Linux execv
    # relaunch. The AppImage's embedded executable cannot be run as a standalone
    # file, so point relaunch at the installed FHS wrapper command.
    extraBwrapArgs = [
      "--setenv"
      "APPIMAGE"
      "/run/current-system/sw/bin/dikte"
    ];
  }
