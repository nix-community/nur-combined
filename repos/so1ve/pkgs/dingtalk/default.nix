{
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  buildFHSEnv,
  cairo,
  callPackage,
  cups,
  dbus,
  dpkg,
  expat,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  glib-networking,
  gtk2,
  gtk3,
  lib,
  libappindicator-gtk3,
  libdbusmenu,
  libdrm,
  libgbm,
  libGL,
  libGLU,
  libice,
  libnotify,
  libpulseaudio,
  libsecret,
  libsm,
  libx11,
  libxcb,
  libxcomposite,
  libxcursor,
  libxdamage,
  libxext,
  libxfixes,
  libxi,
  libxinerama,
  libxkbcommon,
  libxrandr,
  libxrender,
  libxscrnsaver,
  libxtst,
  libxcrypt-legacy,
  makeDesktopItem,
  nspr,
  nss,
  pango,
  pipewire,
  source ? callPackage ./source.nix { },
  stdenv,
  stdenvNoCC,
  systemdLibs,
  util-linux,
  vulkan-loader,
  wayland,
  writeShellScript,
  xdg-utils,
  zenity,
  zlib,
}:

let
  unwrapped = stdenvNoCC.mkDerivation {
    pname = "dingtalk-unwrapped";
    inherit (source) version src;

    strictDeps = true;
    dontBuild = true;
    # The release contains a collection of vendor libraries which must remain
    # together with the application binary.
    dontFixup = true;

    nativeBuildInputs = [ dpkg ];

    unpackPhase = ''
      runHook preUnpack

      dpkg-deb -x "$src" .

      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall

      release_dirs=(opt/apps/com.alibabainc.dingtalk/files/*-Release.*)

      mkdir -p "$out/libexec/dingtalk/release"
      cp -a "''${release_dirs[0]}"/. "$out/libexec/dingtalk/release/"

      if [ -f opt/apps/com.alibabainc.dingtalk/files/version ]; then
        install -Dm444 \
          opt/apps/com.alibabainc.dingtalk/files/version \
          "$out/libexec/dingtalk/version"
      fi

      # Recent official packages carry their icon outside the release payload.
      # Keep it when present, while allowing older package layouts as well.
      icon=$(find opt/apps/com.alibabainc.dingtalk -type f \
        \( -iname '*.png' -o -iname '*.svg' \) -print -quit)
      if [ -n "$icon" ]; then
        icon_name="dingtalk.''${icon##*.}"
        install -Dm444 "$icon" "$out/share/icons/hicolor/256x256/apps/$icon_name"
      fi

      runHook postInstall
    '';
  };

  desktopItem = makeDesktopItem {
    name = "dingtalk";
    desktopName = "DingTalk";
    comment = "DingTalk desktop client";
    exec = "dingtalk %U";
    icon = "dingtalk";
    categories = [
      "Chat"
      "Office"
    ];
    mimeTypes = [
      "x-scheme-handler/dingtalk"
      "x-scheme-handler/dingtalk_std_ind"
    ];
    extraConfig = {
      "Name[zh_CN]" = "钉钉";
      "Comment[zh_CN]" = "钉钉桌面版";
    };
  };

  runScript = writeShellScript "dingtalk-start" ''
    if [[ "''${XMODIFIERS:-}" =~ fcitx ]]; then
      [ -n "''${QT_IM_MODULE:-}" ] || export QT_IM_MODULE=fcitx
      [ -n "''${GTK_IM_MODULE:-}" ] || export GTK_IM_MODULE=fcitx
    elif [[ "''${XMODIFIERS:-}" =~ ibus ]]; then
      [ -n "''${QT_IM_MODULE:-}" ] || export QT_IM_MODULE=ibus
      [ -n "''${GTK_IM_MODULE:-}" ] || export GTK_IM_MODULE=ibus
    fi

    # DingTalk ships the XCB Qt platform plugin, so run it through Xwayland.
    export QT_QPA_PLATFORM="''${QT_QPA_PLATFORM:-xcb}"
    export QT_PLUGIN_PATH="${unwrapped}/libexec/dingtalk/release''${QT_PLUGIN_PATH:+:$QT_PLUGIN_PATH}"
    export GIO_EXTRA_MODULES="${glib-networking}/lib/gio/modules''${GIO_EXTRA_MODULES:+:$GIO_EXTRA_MODULES}"

    release_dir="${unwrapped}/libexec/dingtalk/release"
    if [ -d "$release_dir/plugins/dtwebview" ]; then
      export LD_LIBRARY_PATH="$release_dir/plugins/dtwebview''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
    fi

    cd "$release_dir"
    exec ./com.alibabainc.dingtalk "$@"
  '';
in
buildFHSEnv {
  pname = "dingtalk";
  inherit (source) version;

  targetPkgs = _pkgs: [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    glib-networking
    gtk2
    gtk3
    libappindicator-gtk3
    libdbusmenu
    libdrm
    libgbm
    libGL
    libGLU
    libice
    libnotify
    libpulseaudio
    libsecret
    libsm
    libx11
    libxcb
    libxcomposite
    libxcursor
    libxcrypt-legacy
    libxdamage
    libxext
    libxfixes
    libxi
    libxinerama
    libxkbcommon
    libxrandr
    libxrender
    libxscrnsaver
    libxtst
    nspr
    nss
    pango
    pipewire
    stdenv.cc.cc.lib
    systemdLibs
    util-linux
    vulkan-loader
    wayland
    xdg-utils
    zenity
    zlib
  ];

  runScript = runScript;

  extraInstallCommands = ''
    mkdir -p "$out/share"
    ln -s "${desktopItem}/share/applications" "$out/share/applications"
    if [ -d "${unwrapped}/share/icons" ]; then
      ln -s "${unwrapped}/share/icons" "$out/share/icons"
    fi
  '';

  meta = {
    description = "DingTalk desktop client";
    homepage = "https://www.dingtalk.com/";
    license = lib.licenses.unfree;
    mainProgram = "dingtalk";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
