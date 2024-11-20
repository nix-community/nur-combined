{ stdenv, lib, autoPatchelfHook, fetchurl , buildFHSUserEnvBubblewrap, writeShellScript, makeWrapper, copyDesktopItems, makeDesktopItem
, dpkg
, alsa-lib
, libgcc
, glibc
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

, gcc
, pkg-config
}:
let
  pkg-name = "wemeet-bin";
  # pkg-ver = "3.19.0.401";
  pkg-ver = "3.19.2.400";
  wrap = stdenv.mkDerivation rec {
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
  libraries = [
    alsa-lib
    libgcc
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

    systemdLibs
    dbus
    nspr
    xorg.libXtst
    freetype
    expat
    fontconfig
    harfbuzz
    glib
  ];
  wemeet-src = stdenv.mkDerivation rec {
    name = "${pkg-name}";
    version = "${pkg-ver}";

    src = fetchurl {
      # url = "https://updatecdn.meeting.qq.com/cos/bb4001c715553579a8b3e496233331d4/TencentMeeting_0300000000_${version}_x86_64_default.publish.deb";
      # hash = "sha256-VN/rNn2zA21l6BSzLpQ5Bl9XB2hrMFIa0o0cy2vdLx8=";
      url = "https://updatecdn.meeting.qq.com/cos/fb7464ffb18b94a06868265bed984007/TencentMeeting_0300000000_${version}_x86_64_default.publish.deb";
      hash = "sha256-PSGc4urZnoBxtk1cwwz/oeXMwnI02Mv1pN2e9eEf5kE=";
    };

    nativeBuildInputs = [
        dpkg
        autoPatchelfHook
    ];
    buildInputs = libraries;

    unpackCmd = "dpkg -x $src .";
    sourceRoot = ".";
    
    dontWrapQtApps = true;

    installPhase = ''
      mkdir -p $out;
      rm opt/wemeet/lib/libcurl.so
      cp -r . $out
    '';
  };
  startScript = writeShellScript "wemeet-start" ''
    export LD_LIBRARY_PATH=/opt/wemeet/lib:${lib.makeLibraryPath libraries}
    export LD_PRELOAD=''${LD_PRELOAD:-}:${wrap}/libwemeetwrap.so
    export XDG_SESSION_TYPE=x11
    export EGL_PLATFORM=x11
    export QT_QPA_PLATFORM=xcb
    unset WAYLAND_DISPLAY
    exec /opt/wemeet/bin/wemeetapp
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
    echo 'Installing icons...'
    for res in 16 32 64 128 256; do
        install -Dm644 \
            ${wemeet-src}/opt/wemeet/icons/hicolor/''${res}x''${res}/mimetypes/wemeetapp.png \
            $out/share/icons/hicolor/''${res}x''${res}/apps/${pkg-name}.png
    done
    makeWrapper ${fhs}/bin/${pkg-name} $out/bin/${pname} \
      --run "mkdir -p \$HOME/.local/share/wemeetapp"
    runHook postInstall
  '';

  meta = with lib; {
    description = ''
      Tencent Meeting Linux Client
      (Adapted from https://aur.archlinux.org/packages/wemeet-bin)
    '';
    homepage = "https://source.meeting.qq.com";
    platforms = [ "x86_64-linux" ];
    license = licenses.unfreeRedistributable;
  };

}
