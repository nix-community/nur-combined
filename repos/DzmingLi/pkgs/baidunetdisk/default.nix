{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  patchelf,
  gtk2,
  atkmm,
  libsigcxx_2_0,
  makeWrapper,
  wrapGAppsHook3,
  makeDesktopItem,
  copyDesktopItems,
  callPackage,
  glibmm_2_4,
  cairomm_1_0,
  pangomm_1_4,
  alsa-lib,
  at-spi2-atk,
  cairo,
  cups,
  dbus,
  expat,
  glib,
  gtk3,
  libdrm,
  libx11,
  libxcb,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxrandr,
  libxkbcommon,
  libxshmfence,
  libxtst,
  libxt,
  nspr,
  nss,
  pango,
  systemd,
  libappindicator,
  libdbusmenu,
  libgbm,
  libglvnd,
}:
# Adapted from xddxdd/nur-packages (MIT):
# https://github.com/xddxdd/nur-packages/blob/f7aa179dbae42b567c2a3c6e20ca41a3c4a1b05c/pkgs/uncategorized/baidunetdisk/default.nix
# Keep the vendor Electron runtime: electron-panel-window requires module ABI 110.
let
  version = "8.7.0";
  # The vendor browser engine still uses GTK 2's C++ ABI.
  gtkmm2 = callPackage ./gtkmm2.nix {
    glibmm = glibmm_2_4;
    cairomm = cairomm_1_0;
    pangomm = pangomm_1_4;
  };

  src = fetchurl {
    url = "https://pkg-ant.baidu.com/issue/netdisk/LinuxGuanjia/${version}/baidunetdisk_${version}_amd64.deb";
    hash = "sha256-7HHCrRFRYJ/Q2LhtlRhMC0V9bbWqGIYeCxX8I8z+Afc=";
  };

  libraries = [
    alsa-lib
    at-spi2-atk
    cairo
    cups
    dbus
    expat
    glib
    gtk3
    libdrm
    libx11
    libxcb
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    libxkbcommon
    libxshmfence
    nspr
    nss
    pango
    systemd
    stdenv.cc.cc.lib
    libappindicator
    libdbusmenu
    libgbm
    libglvnd
    gtkmm2
    gtk2
    atkmm
    glibmm_2_4
    cairomm_1_0
    pangomm_1_4
    libsigcxx_2_0
  ];

  dist = stdenv.mkDerivation {
    pname = "baidunetdisk-unwrapped";
    inherit version src;
    nativeBuildInputs = [
      dpkg
      patchelf
    ];
    # resources/version validates the native engine's bytes; automatic ELF
    # fixups or stripping make the application exit during initialization.
    dontFixup = true;
    dontBuild = true;

    unpackPhase = ''
      runHook preUnpack
      dpkg-deb -x $src .
      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib/baidunetdisk
      cp -r opt/baidunetdisk/. $out/lib/baidunetdisk/
      # Remove node-gyp's accidentally bundled build-time Python executables.
      rm -rf $out/lib/baidunetdisk/resources/app.asar.unpacked/node_modules/{windows-notification-state,macos-notification-state,windows-quiet-hours}/build/node_gyp_bins
      # Only executable interpreters need patching. Shared libraries must retain
      # their upstream contents and are resolved by the launcher's library path.
      for program in baidunetdisk baidunetdiskhost chrome_crashpad_handler netdisk_service; do
        patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
          $out/lib/baidunetdisk/$program
      done
      runHook postInstall
    '';
  };
in
stdenv.mkDerivation {
  pname = "baidunetdisk";
  inherit version;
  dontUnpack = true;
  dontBuild = true;
  strictDeps = true;
  nativeBuildInputs = [
    makeWrapper
    wrapGAppsHook3
    copyDesktopItems
  ];
  buildInputs = [ gtk3 ];
  dontWrapGApps = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -Dm644 ${dist}/lib/baidunetdisk/baidunetdisk.svg $out/share/icons/hicolor/scalable/apps/baidunetdisk.svg
    runHook postInstall
  '';

  preFixup = ''
    makeWrapper ${dist}/lib/baidunetdisk/baidunetdisk $out/bin/baidunetdisk \
      "''${gappsWrapperArgs[@]}" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath (libraries ++ [ libxtst libxt ])}:${dist}/lib/baidunetdisk" \
      --add-flags "--no-sandbox"
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "baidunetdisk";
      desktopName = "Baidu Netdisk";
      exec = "baidunetdisk %U";
      terminal = false;
      icon = "baidunetdisk";
      startupWMClass = "baidunetdisk";
      comment = "Baidu Netdisk";
      mimeTypes = [ "x-scheme-handler/baiduyunguanjia" ];
      categories = [ "Network" ];
      extraConfig = {
        "Name[zh_CN]" = "百度网盘";
        "Name[zh_TW]" = "百度網盤";
        "Comment[zh_CN]" = "百度网盘";
        "Comment[zh_TW]" = "百度網盤";
      };
    })
  ];

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Baidu Netdisk";
    homepage = "https://pan.baidu.com/";
    downloadPage = "https://pan.baidu.com/download";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    license = lib.licenses.unfreeRedistributable;
    mainProgram = "baidunetdisk";
  };
}
