# Copy from:
#   https://github.com/novel2430/MyNUR/blob/master/pkgs/wemeet-bin-bwrap/default.nix

{
  stdenv,
  lib,
  autoPatchelfHook,
  fetchurl,
  buildFHSEnvBubblewrap,
  writeShellScript,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
  fetchFromGitHub,
  dpkg,
  alsa-lib,
  libgcc,
  glibc,
  libglvnd,
  libpulseaudio,
  xorg,
  openssl,
  libsForQt5,
  zlib,
  wayland,
  nss,
  curl,
  libxkbcommon,
  # Wayland Screenshare hack
  gcc,
  pkg-config,
  git,
  cmake,
  ninja,
  libportal,
  opencv,
  pipewire,
  libsysprof-capture,
  util-linux,
  libselinux,
  libsepol,
}:
let
  ld-preload-path = "${wrap}/libwemeetwrap.so:${wemeet-wayland-screenshare}/libhook.so";

  libraries = [
    alsa-lib
    libgcc
    glibc
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
    libxkbcommon
    opencv
  ];

  wrap = stdenv.mkDerivation {
    name = "wrap-c";
    version = "1.0";
    src = ./.;

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
      rev = "d2f0f3b3ac0dce2c890d68c38e8f253ea7ab23ca";
      sha256 = "sha256-/YWZu0DNJs9DigjBCUjbVHqFwK4qva+kRqkzwg3fOKs=";
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
  pkg-name = "wemeet-bin";
  pkg-ver = "3.19.0.401";
  wemeet-src = stdenv.mkDerivation rec {
    name = "${pkg-name}";
    version = "${pkg-ver}";

    src = fetchurl {
      url = "https://updatecdn.meeting.qq.com/cos/bb4001c715553579a8b3e496233331d4/TencentMeeting_0300000000_${version}_x86_64_default.publish.deb";
      hash = "sha256-VN/rNn2zA21l6BSzLpQ5Bl9XB2hrMFIa0o0cy2vdLx8=";
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
    export LD_LIBRARY_PATH=/lib:/opt/wemeet/lib

    # Wayland Screenshare Hack
    if [ "$XDG_SESSION_TYPE" != "wayland" ]; then
      echo "Not in Wayland"
      export LD_PRELOAD="${wrap}/libwemeetwrap.so"
    else
      export LD_PRELOAD=${ld-preload-path}
    fi

    # fcitx5
    if [[ ''${XMODIFIERS} =~ fcitx ]]; then
      export QT_IM_MODULE=fcitx
      export GTK_IM_MODULE=fcitx
    elif [[ ''${XMODIFIERS} =~ ibus ]]; then
      export QT_IM_MODULE=ibus
    fi
    export XDG_SESSION_TYPE=x11
    export EGL_PLATFORM=x11
    export QT_QPA_PLATFORM=xcb
    unset WAYLAND_DISPLAY
    exec /opt/wemeet/bin/wemeetapp
  '';

  fhs = buildFHSEnvBubblewrap {
    name = "${pkg-name}";
    targetPkgs =
      pkgs:
      [
        wemeet-src
      ]
      ++ libraries;
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
      categories = [
        "Utility"
        "Network"
        "InstantMessaging"
        "Chat"
      ];
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
    runHook preInstall

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
    description = "Tencent Meeting Linux Client";
    homepage = "https://source.meeting.qq.com";
    platforms = [ "x86_64-linux" ];
    license = licenses.unfreeRedistributable;
  };
}
