{
  alsa-lib,
  at-spi2-atk,
  atkmm,
  buildFHSEnv,
  cairo,
  cairomm_1_0,
  callPackage,
  cups,
  dbus,
  dpkg,
  expat,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  glibmm_2_4,
  gtk2,
  gtk3,
  lib,
  libGL,
  libappindicator-gtk3,
  libdbusmenu,
  libdrm,
  libgbm,
  libnotify,
  libpulseaudio,
  libsecret,
  libsigcxx_2_0,
  libva,
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
  libxscrnsaver,
  libxt,
  libxtst,
  makeDesktopItem,
  makeFontsConf,
  noto-fonts-cjk-sans,
  nspr,
  nss,
  pango,
  pangomm_1_4,
  procps,
  runCommand,
  source ? callPackage ./source.nix { },
  stdenvNoCC,
  systemdLibs,
  xdg-utils,
}:

let
  # nixpkgs marks GTK 2 broken because it is deprecated, but the vendor's
  # browser engine still requires its ABI and cannot be rebuilt against GTK 3.
  gtk2ForBaidu = gtk2.overrideAttrs (previous: {
    meta = previous.meta // {
      problems = builtins.removeAttrs previous.meta.problems [ "broken" ];
    };
  });

  # The vendor's libbrowserengine.so still links against GTKmm 2.4.
  gtkmm2 = callPackage ./gtkmm2.nix { gtk2 = gtk2ForBaidu; };

  fontsConf = makeFontsConf {
    fontDirectories = [ noto-fonts-cjk-sans ];
    # Electron 22's bundled fontconfig cannot parse some rules from current
    # NixOS releases, so do not include the host's /etc/fonts/conf.d.
    includes = [ ];
  };

  fontsConfDir = runCommand "baidunetdisk-fontconfig" { } ''
    mkdir -p "$out"
    ln -s "${fontsConf}" "$out/fonts.conf"
  '';

  unwrapped = stdenvNoCC.mkDerivation {
    pname = "baidunetdisk-unwrapped";
    inherit (source) version src;

    strictDeps = true;
    dontBuild = true;
    # This release is sensitive to modifications of its bundled native
    # binaries, so keep the vendor payload byte-for-byte intact.
    dontFixup = true;

    nativeBuildInputs = [ dpkg ];

    unpackPhase = ''
      runHook preUnpack

      dpkg-deb -x "$src" .

      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/libexec"
      cp -a opt/baidunetdisk "$out/libexec/"

      install -Dm444 \
        "$out/libexec/baidunetdisk/baidunetdisk.svg" \
        "$out/share/icons/hicolor/scalable/apps/baidunetdisk.svg"

      runHook postInstall
    '';
  };

  desktopItem = makeDesktopItem {
    name = "baidunetdisk";
    desktopName = "Baidu Netdisk";
    comment = "Baidu Netdisk desktop client";
    exec = "baidunetdisk %U";
    icon = "baidunetdisk";
    startupWMClass = "baidunetdisk";
    categories = [ "Network" ];
    mimeTypes = [ "x-scheme-handler/baiduyunguanjia" ];
    extraConfig = {
      "Name[zh_CN]" = "百度网盘";
      "Name[zh_TW]" = "百度網盤";
      "Comment[zh_CN]" = "百度网盘桌面客户端";
      "Comment[zh_TW]" = "百度網盤桌面用戶端";
    };
  };
in
buildFHSEnv {
  pname = "baidunetdisk";
  inherit (source) version;

  targetPkgs = _pkgs: [
    alsa-lib
    at-spi2-atk
    atkmm
    cairo
    cairomm_1_0
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    glibmm_2_4
    gtk2ForBaidu
    gtk3
    gtkmm2
    libGL
    libappindicator-gtk3
    libdbusmenu
    libdrm
    libgbm
    libnotify
    libpulseaudio
    libsecret
    libsigcxx_2_0
    libva
    libx11
    libxcb
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    libxinerama
    libxkbcommon
    libxrandr
    libxscrnsaver
    libxt
    libxtst
    nspr
    nss
    pango
    pangomm_1_4
    procps
    systemdLibs
    xdg-utils
  ];

  runScript = "${unwrapped}/libexec/baidunetdisk/baidunetdisk --no-sandbox";

  # Do not let buildFHSEnv expose the host's incompatible fontconfig rules.
  extraPreBwrapCmds = ''
    etc_ignored+=("/etc/fonts")
  '';

  extraBwrapArgs = [
    "--ro-bind"
    "${fontsConfDir}"
    "/etc/fonts"
  ];

  profile = ''
    export FONTCONFIG_FILE="${fontsConf}"
    export TMPDIR="''${XDG_RUNTIME_DIR:-/tmp}/baidunetdisk"
    mkdir -p "$TMPDIR"
  '';

  extraInstallCommands = ''
    mkdir -p "$out/share"
    ln -s "${desktopItem}/share/applications" "$out/share/applications"
    ln -s "${unwrapped}/share/icons" "$out/share/icons"
  '';

  meta = {
    description = "Official desktop client for Baidu Netdisk";
    homepage = "https://pan.baidu.com/";
    license = lib.licenses.unfreeRedistributable;
    mainProgram = "baidunetdisk";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
