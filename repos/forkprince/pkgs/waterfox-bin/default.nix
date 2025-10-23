{
  wrapGAppsHook3,
  makeDesktopItem,
  libappindicator,
  at-spi2-core,
  libxkbcommon,
  libpulseaudio,
  gdk-pixbuf,
  libXScrnSaver,
  libXcomposite,
  libXcursor,
  libXdamage,
  libXrender,
  makeWrapper,
  at-spi2-atk,
  libnotify,
  dbus-glib,
  patchelf,
  writeText,
  fetchurl,
  alsa-lib,
  pciutils,
  systemd,
  libdrm,
  libXfixes,
  libXrandr,
  libxcb,
  libXtst,
  stdenv,
  libXext,
  libX11,
  libXi,
  ffmpeg,
  libGL,
  cairo,
  cups,
  mesa,
  nspr,
  pango,
  unzip,
  atk,
  gtk3,
  glib,
  nss,
  lib,
}: let
  info = builtins.fromJSON (builtins.readFile ./info.json);

  desktopItem = makeDesktopItem {
    name = "waterfox";
    exec = "waterfox %U";
    icon = "waterfox";
    desktopName = "Waterfox";
    genericName = "Web Browser";
    categories = [
      "Network"
      "WebBrowser"
    ];
    mimeTypes = [
      "text/html"
      "text/xml"
      "application/xhtml+xml"
      "application/vnd.mozilla.xul+xml"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
      "x-scheme-handler/ftp"
    ];
  };

  prefsFile = writeText "waterfox-prefs.js" ''
    // Disable automatic updates and notifications
    pref("app.update.auto", false);
    pref("app.update.enabled", false);
    pref("browser.crashReports.unsubmittedCheck.enabled", false);
  '';
in
  stdenv.mkDerivation rec {
    pname = "waterfox-bin";
    inherit (info) version;

    src = fetchurl {
      url = "https://cdn1.waterfox.net/waterfox/releases/${version}/Linux_x86_64/waterfox-${version}.tar.bz2";
      inherit (info) hash;
    };

    nativeBuildInputs = [
      wrapGAppsHook3
      patchelf
      makeWrapper
      unzip
    ];

    buildInputs = [
      stdenv.cc.cc.lib
      libappindicator
      at-spi2-core
      libxkbcommon
      libpulseaudio
      gdk-pixbuf
      libXScrnSaver
      libXcomposite
      libXcursor
      libXdamage
      libXrender
      at-spi2-atk
      libnotify
      dbus-glib
      alsa-lib
      pciutils
      systemd
      libdrm
      libXfixes
      libXrandr
      libxcb
      libXtst
      libXext
      libX11
      libXi
      ffmpeg
      libGL
      cairo
      cups
      mesa
      nspr
      pango
      atk
      gtk3
      glib
      nss
    ];

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/{bin,opt,share/applications}
      cp -r . $out/opt/waterfox

      makeWrapper $out/opt/waterfox/waterfox-bin $out/bin/waterfox \
        --set GTK_IM_MODULE gtk-im-context-simple \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}"

      cp ${desktopItem}/share/applications/* $out/share/applications/

      mkdir -p $out/share/icons/hicolor/256x256/apps
      cp $out/opt/waterfox/browser/chrome/icons/default/default256.png \
        $out/share/icons/hicolor/256x256/apps/waterfox.png

      mkdir -p $out/opt/waterfox/browser/defaults/preferences
      cp ${prefsFile} $out/opt/waterfox/browser/defaults/preferences/nix-prefs.js

      runHook postInstall
    '';

    postInstall = ''
      find $out/opt/waterfox -type f -name "*.so" -exec sh -c '
        if patchelf --print-interpreter "{}" >/dev/null 2>&1; then
          patchelf \
            --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
            --set-rpath "${lib.makeLibraryPath buildInputs}:$out/opt/waterfox" \
            "{}"
        fi
      ' \;

      patchelf \
        --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        --set-rpath "${lib.makeLibraryPath buildInputs}:$out/opt/waterfox" \
        $out/opt/waterfox/waterfox-bin

      patchelf \
        --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        --set-rpath "${lib.makeLibraryPath buildInputs}:$out/opt/waterfox" \
        $out/opt/waterfox/glxtest

      patchelf \
        --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        --set-rpath "${lib.makeLibraryPath buildInputs}:$out/opt/waterfox" \
        $out/opt/waterfox/vaapitest

      cp -L ${nspr}/lib/libnspr4.so $out/opt/waterfox/
      cp -L ${nspr}/lib/libplc4.so $out/opt/waterfox/
      cp -L ${nspr}/lib/libplds4.so $out/opt/waterfox/

      for lib in ${nss}/lib/lib{nss3,nssutil3,smime3,ssl3}.so; do
        if [ ! -e $out/opt/waterfox/$(basename $lib) ]; then
          cp -L $lib $out/opt/waterfox/
        fi
      done
    '';

    preFixup = ''
      gappsWrapperArgs+=(
        --prefix XDG_DATA_DIRS : "$XDG_ICON_DIRS:$GSETTINGS_SCHEMAS_PATH:$out/share"
      )
    '';

    meta = {
      description = "Fast and Private Web Browser";
      homepage = "https://www.waterfox.net/";
      changelog = "https://www.waterfox.net/docs/releases/${version}/";
      license = lib.licenses.mpl20;
      platforms = ["x86_64-linux"];
      maintainers = ["JoyfulCat" "Prinky"];
      mainProgram = "waterfox";
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
    };
  }
