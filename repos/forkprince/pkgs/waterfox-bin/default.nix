{
  makeDesktopItem,
  libappindicator,
  wrapGAppsHook3,
  libpulseaudio,
  at-spi2-core,
  libxkbcommon,
  at-spi2-atk,
  ffmpeg-full,
  makeWrapper,
  gdk-pixbuf,
  dbus-glib,
  writeText,
  libnotify,
  alsa-lib,
  fetchurl,
  patchelf,
  pciutils,
  systemd,
  libdrm,
  libxcb,
  stdenv,
  cairo,
  libGL,
  pango,
  unzip,
  _7zz,
  cups,
  glib,
  gtk3,
  mesa,
  nspr,
  xorg,
  atk,
  lib,
  nss,
}: let
  ver = lib.helper.read ./version.json;
  platform = stdenv.hostPlatform.system;

  pname = "waterfox";

  inherit (ver) version;

  src = fetchurl (lib.helper.getPlatform platform ver);

  meta = {
    description = "Fast and Private Web Browser";
    homepage = "https://www.waterfox.net/";
    changelog = "https://www.waterfox.net/docs/releases/${version}/";
    license = lib.licenses.mpl20;
    platforms = ["x86_64-linux" "x86_64-darwin" "aarch64-darwin"];
    maintainers = ["JoyfulCat" "Prinky"];
    mainProgram = "waterfox";
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
in
  if stdenv.isDarwin
  then
    stdenv.mkDerivation {
      inherit pname version src meta;

      nativeBuildInputs = [_7zz];

      sourceRoot = ".";

      dontBuild = true;
      dontFixup = true;

      installPhase = ''
        runHook preInstall
        mkdir -p $out/Applications
        cp -r Waterfox.app $out/Applications/
        runHook postInstall
      '';
    }
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
        xorg.libXcomposite
        xorg.libXScrnSaver
        stdenv.cc.cc.lib
        libappindicator
        xorg.libXcursor
        xorg.libXdamage
        xorg.libXrender
        xorg.libXfixes
        xorg.libXrandr
        libpulseaudio
        xorg.libXext
        xorg.libXtst
        at-spi2-core
        libxkbcommon
        at-spi2-atk
        ffmpeg-full
        xorg.libX11
        xorg.libXi
        gdk-pixbuf
        dbus-glib
        libnotify
        alsa-lib
        pciutils
        systemd
        libdrm
        libxcb
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
    }
