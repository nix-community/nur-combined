{
  ffmpeg_9 ? ffmpeg,
  makeDesktopItem,
  libappindicator,
  wrapGAppsHook3,
  libpulseaudio,
  libXcomposite,
  libXScrnSaver,
  at-spi2-core,
  libxkbcommon,
  at-spi2-atk,
  makeWrapper,
  gdk-pixbuf,
  libXcursor,
  libXdamage,
  libXrender,
  dbus-glib,
  writeText,
  libnotify,
  libXfixes,
  libXrandr,
  alsa-lib,
  fetchurl,
  patchelf,
  pciutils,
  libXext,
  systemd,
  libXtst,
  ffmpeg,
  libX11,
  libdrm,
  libxcb,
  stdenv,
  cairo,
  libGL,
  pango,
  unzip,
  libXi,
  _7zz,
  cups,
  glib,
  gtk3,
  mesa,
  nspr,
  atk,
  lib,
  nss,
}: let
  ver = lib.helper.read ./version.json;

  pname = "waterfox";

  inherit (ver) version;

  src = fetchurl (lib.helper.getPlatform stdenv.hostPlatform.system ver);

  meta = {
    description = "Fast and Private Web Browser";
    homepage = "https://www.waterfox.net/";
    changelog = "https://www.waterfox.net/docs/releases/${version}/";
    license = lib.licenses.mpl20;
    platforms = lib.platforms.darwin ++ lib.platforms.linux;
    maintainers = with lib.maintainers; [JoyfulCat Prinky];
    mainProgram = "waterfox";
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
in
  if stdenv.hostPlatform.isDarwin
  then
    stdenv.mkDerivation (lib.helper.mkDarwin {
      inherit pname version src meta;

      nativeBuildInputs = [_7zz];
    })
  else let
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
      inherit pname version src meta;

      nativeBuildInputs = [
        wrapGAppsHook3
        makeWrapper
        patchelf
        unzip
      ];

      buildInputs = [
        stdenv.cc.cc.lib
        libappindicator
        libXcomposite
        libXScrnSaver
        libpulseaudio
        libxkbcommon
        at-spi2-core
        at-spi2-atk
        libXcursor
        libXdamage
        libXrender
        gdk-pixbuf
        libXfixes
        libXrandr
        libnotify
        dbus-glib
        alsa-lib
        ffmpeg_9
        pciutils
        systemd
        libXext
        libXtst
        libdrm
        libxcb
        libX11
        libXi
        cairo
        libGL
        pango
        cups
        glib
        gtk3
        mesa
        nspr
        atk
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
        find $out/opt/waterfox -type f -exec sh -c '
          if patchelf --print-interpreter "{}" >/dev/null 2>&1; then
            patchelf \
              --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
              --set-rpath "${lib.makeLibraryPath buildInputs}:$out/opt/waterfox" \
              "{}"
          fi
        ' \;

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
    }
