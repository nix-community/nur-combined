{ stdenv, lib, autoPatchelfHook, fetchurl , buildFHSUserEnvBubblewrap, writeShellScript, makeWrapper, copyDesktopItems, makeDesktopItem, wrapQtAppsHook, fetchFromGitHub
, useWaylandScreenshare ? false
, dpkg
, alsa-lib
, libglvnd
, libpulseaudio
, xorg
, openssl
, libsForQt5
, zlib
, wayland
, nss
, curl

, systemdLibs
, dbus
, nspr
, freetype
, expat
, fontconfig
, harfbuzz
, glib
, xkeyboard_config

, gcc
, pkg-config

, libyuv
, libjpeg8
, libxkbcommon


, git
, cmake
, ninja
, libportal
, opencv
, pipewire
, libsysprof-capture
, util-linux
, libselinux
, libsepol
}:
let
  pkg-name = "wemeet-bin";
  pkg-ver = "3.19.0.401";
  # pkg-ver = "3.19.2.400";
  wrap = stdenv.mkDerivation {
    name = "wrap-c";
    version = "1.0";
    src = ./.;


    # unpackCmd = "";

    dontWrapQtApps = true;

    nativeBuildInputs = [
      gcc
      pkg-config
    ];
    buildInputs = libraries;

    buildPhase = ''
      read -ra openssl_args < <(pkg-config --libs openssl)
      read -ra libpulse_args < <(pkg-config --cflags --libs libpulse)
      # Comment out `-D WRAP_FORCE_SINK_HARDWARE` to disable the patch that forces wemeet detects sink as hardware sink
      gcc $CFLAGS -Wall -Wextra -fPIC -shared "''${openssl_args[@]}" "''${libpulse_args[@]}" -o libwemeetwrap.so wrap.c -D WRAP_FORCE_SINK_HARDWARE
    '';
    installPhase = ''
      mkdir -p $out;
      install -Dm755 ./libwemeetwrap.so $out/libwemeetwrap.so
    '';
  };
  # https://github.com/xuwd1/wemeet-wayland-screenshare
  wemeet-wayland-screenshare = stdenv.mkDerivation {
    name = "wemeet-wayland-screenshare";
    version = "0.0.1";
    src = fetchFromGitHub {
      owner = "xuwd1";
      repo = "wemeet-wayland-screenshare";
      rev = "6deba6e18f74984ebf0d4eba0c3fe07a7bdd7ea6";
      sha256 = "sha256-xl485d+DwiDGTlJYzg0Eb+pJ+KaetF9+rPW9aZAeXOw=";
    };
    nativeBuildInputs = [
      gcc
      pkg-config
      git
      cmake
      ninja
    ];

    buildInputs = [
      libportal
      xorg.libXrandr
      xorg.libXdamage
      opencv
      libsForQt5.qt5.qtwayland
      libsForQt5.xwaylandvideobridge
      pipewire
      libsysprof-capture
      util-linux
      libselinux
      libsepol
    ];

    dontWrapQtApps = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out;
      install -Dm755 "./libhook.so" "$out/libhook.so"
      runHook postInstall
    '';
  };
  libraries = [
    alsa-lib
    stdenv.cc.libc
    libglvnd
    libpulseaudio
    xorg.libX11
    xorg.libXcomposite
    xorg.libXdamage
    xorg.xset
    xorg.libXfixes
    xorg.libXinerama
    xorg.libXrandr
    openssl
    libsForQt5.qt5.qtbase
    libsForQt5.qt5.qtdeclarative
    libsForQt5.qt5.qtsvg
    libsForQt5.qt5.qtwebchannel
    libsForQt5.qt5.qtwebengine
    libsForQt5.qt5.qtx11extras
    libsForQt5.qt5.qtwayland
    zlib
    wayland
    nss
    curl
    xkeyboard_config

    systemdLibs
    dbus
    nspr
    xorg.libXtst
    freetype
    expat
    fontconfig
    harfbuzz
    glib

    libyuv
    libjpeg8
    libxkbcommon

    opencv
  ];
  ld-preload-path = 
    if useWaylandScreenshare then
      "${wemeet-wayland-screenshare}/libhook.so:${wrap}/libwemeetwrap.so"
    else
      "${wrap}/libwemeetwrap.so";
  wemeet-src = stdenv.mkDerivation rec {
    name = "${pkg-name}";
    version = "${pkg-ver}";

    src = fetchurl {
      url = "https://updatecdn.meeting.qq.com/cos/bb4001c715553579a8b3e496233331d4/TencentMeeting_0300000000_${version}_x86_64_default.publish.deb";
      hash = "sha256-VN/rNn2zA21l6BSzLpQ5Bl9XB2hrMFIa0o0cy2vdLx8=";
      # url = "https://updatecdn.meeting.qq.com/cos/fb7464ffb18b94a06868265bed984007/TencentMeeting_0300000000_${version}_x86_64_default.publish.deb";
      # hash = "sha256-PSGc4urZnoBxtk1cwwz/oeXMwnI02Mv1pN2e9eEf5kE=";
    };

    nativeBuildInputs = [
        dpkg
        autoPatchelfHook
        wrapQtAppsHook
    ];
    buildInputs = libraries;

    unpackCmd = "dpkg -x $src .";
    sourceRoot = ".";

    installPhase = ''
      mkdir -p $out/opt/wemeet;
      rm opt/wemeet/lib/libcurl.so
      # libbugly is not likely to be necessary
      install -Dm755 opt/wemeet/lib/lib{desktop_common,ImSDK,nxui*,qt_*,service*,tms_*,ui*,wemeet*,xcast*,xnn*}.so \
          -t "$out/lib/wemeet"
      if [ -f 'opt/wemeet/lib/libcrbase.so' ]; then
          install -Dm755 opt/wemeet/lib/libcrbase.so -t "$out/lib/wemeet"
      else
          echo 'lib/libcrbase.so not found'
      fi
      # copy Qt
      cp -r opt/wemeet/plugins opt/wemeet/resources opt/wemeet/translations "$out/lib/wemeet"
      cp -a opt/wemeet/lib/lib{Qt,icu}* "$out/lib/wemeet"
      # bin
      cp -r opt/wemeet/bin $out/opt/wemeet
      sed -i "s|^Prefix.*|Prefix = $out/lib/wemeet|" $out/opt/wemeet/bin/qt.conf
      ln -s raw/xcast.conf "$out/opt/wemeet/bin/xcast.conf"
      # wrap
      install -Dm755 "${wrap}/libwemeetwrap.so" -t "$out/lib/wemeet"
      # Icon
      echo 'Installing icons...'
      for res in 16 32 64 128 256; do
          install -Dm644 \
              opt/wemeet/icons/hicolor/''${res}x''${res}/mimetypes/wemeetapp.png \
              $out/share/icons/hicolor/''${res}x''${res}/apps/${pkg-name}.png
      done
    '';
  };
  startScript = writeShellScript "wemeet-start" ''
    export LD_LIBRARY_PATH=${wemeet-src}/lib/wemeet:${lib.makeLibraryPath libraries}
    export LD_PRELOAD=${ld-preload-path}
    export XDG_SESSION_TYPE=x11
    export EGL_PLATFORM=x11
    export QT_QPA_PLATFORM=xcb
    unset WAYLAND_DISPLAY
    exec ${wemeet-src}/opt/wemeet/bin/wemeetapp
  '';
  fhs = buildFHSUserEnvBubblewrap {
    name = "${pkg-name}";
    targetPkgs = 
      pkgs: [
        wemeet-src
      ] 
      ++ 
      libraries;
    runScript = startScript;
    extraBwrapArgs = [
      "--tmpfs \$HOME/.config "
      "--bind \$HOME/.local/share/wemeetapp{,}"
      "--ro-bind-try \${HOME}/.fontconfig{,}"
      "--ro-bind-try \${HOME}/.fonts{,}"
      "--ro-bind-try \${HOME}/.config/fontconfig{,}"
      "--ro-bind-try \${HOME}/.local/share/fonts{,}"
      "--ro-bind-try \${HOME}/.icons{,}"
      "--ro-bind-try \${HOME}/.local/share/.icons{,}"
    ];
  };
in
stdenv.mkDerivation rec {
  pname = "${pkg-name}-bwrap";
  version = "${pkg-ver}";
  dontUnpack = true;
  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
  ];
  desktopItems = [
    (makeDesktopItem {
      name = "${pkg-name}";
      desktopName = "Tencent Meeting";
      exec = "${pname} %U";
      terminal = false;
      icon = "${pkg-name}";
      comment = "Tencent Meeting Linux Client";
      categories = [ "Utility" "Network" "InstantMessaging" "Chat" ];
      keywords = [
        "wemeet"
        "${pkg-name}"
        "tencent"
        "meeting"
      ];
      extraConfig = {
        "Name[zh_CN]" = "腾讯会议Linux客户端";
        "Comment[zh_CN]" = "腾讯会议Linux客户端";
      };
    })
  ];
  installPhase = ''
    makeWrapper ${fhs}/bin/${pkg-name} $out/bin/${pname} \
      --run "mkdir -p \$HOME/.local/share/wemeetapp"
    runHook postInstall
  '';

  meta = with lib; {
    description = ''
      Tencent Meeting Linux Client
      (Support Wayland Native Screenshare)
      (Adapted from https://aur.archlinux.org/packages/wemeet-bin)
    '';
    homepage = "https://source.meeting.qq.com";
    platforms = [ "x86_64-linux" ];
    license = licenses.unfreeRedistributable;
  };

}
