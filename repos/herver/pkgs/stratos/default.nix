{
  lib,
  stdenv,
  fetchurl,
  asar,
  appimageTools,
  autoPatchelfHook,
  makeWrapper,
  pkgs,
}:

let
  version = "2.19.0";
  pname = "stratos";

  # sha512 published by upstream in latest-linux.yml / latest-linux-arm64.yml
  sources = {
    x86_64-linux = {
      arch = "x86_64";
      hash = "sha512-a+PJ6joK+Yy/mCuOgsC/EhWY3iCw/YdyyyBpsQux1/rf65M9qqAGlObogpu3+zbPqB5zlZMk4UsFWwVRKr8hag==";
    };
    aarch64-linux = {
      arch = "arm64";
      hash = "sha512-TTkHUS4IJD1Ia7ujjU1g+UbmmpP+cgOVRDO9/+KT7V0wohX3uwDq6mD6JrPxfcEaWDQ6C6bWWdCi19OfcxAd/Q==";
    };
  };

  source =
    sources.${stdenv.hostPlatform.system}
      or (throw "stratos: unsupported system ${stdenv.hostPlatform.system}");

  src = fetchurl {
    url = "https://cdn.skyvexsoftware.com/stratos/release/Stratos-${version}-${source.arch}.AppImage";
    inherit (source) hash;
  };

  appimageContents = appimageTools.extract {
    inherit pname version src;
  };
in
stdenv.mkDerivation {
  inherit pname version;

  src = appimageContents;

  nativeBuildInputs = [
    asar
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = with pkgs; [
    alsa-lib
    at-spi2-core
    cairo
    cups
    dbus
    expat
    glib
    gtk3
    libdrm
    libxkbcommon
    mesa
    nspr
    nss
    pango
    stdenv.cc.cc.lib
    xorg.libX11
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrandr
    xorg.libxcb
    xorg.libxshmfence
  ];

  # Outside an AppImage ($APPIMAGE unset) electron-updater's checkForUpdates()
  # resolves null without emitting any event, so the startup "shell update"
  # check waits for its 15s timeout before opening the window. Emit
  # update-not-available instead, which is what the app itself reports when
  # its updater is disabled (unpackaged mode).
  postPatch = ''
    asar extract resources/app.asar app
    rm -r resources/app.asar resources/app.asar.unpacked

    updaterJs=$(grep -lF 'checkForUpdates(){if(!this.isUpdaterActive())return Promise.resolve(null);' app/out/main/*.js)
    substituteInPlace "$updaterJs" --replace-fail \
      'checkForUpdates(){if(!this.isUpdaterActive())return Promise.resolve(null);' \
      'checkForUpdates(){if(!this.isUpdaterActive())return this.emit("update-not-available",null),Promise.resolve(null);'

    # The stratos:// handler .desktop file written to ~/.local/share/applications
    # execs $APPIMAGE or the raw Electron binary; point it at the wrapper, which
    # carries --no-sandbox and the runtime environment.
    handlerJs=$(grep -lF 'process.env.APPIMAGE||process.execPath' app/out/main/*.js)
    substituteInPlace "$handlerJs" --replace-fail \
      'process.env.APPIMAGE||process.execPath' \
      "\"$out/bin/stratos\""

    # musl prebuilds cannot be patched against glibc and are never loaded here
    find app -name '*.musl.node' -delete

    asar pack app resources/app.asar --unpack '*.node'
    rm -r app
  '';

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib/stratos $out/share/applications
    # Skip AppRun, chrome-sandbox and usr/lib (bundled legacy libs like libgconf are not needed by Electron)
    cp -r locales resources *.pak *.bin *.dat *.so *.so.1 *.json \
      chrome_crashpad_handler Stratos $out/lib/stratos/
    cp -r usr/share/icons $out/share/

    cp Stratos.desktop $out/share/applications/stratos.desktop
    substituteInPlace $out/share/applications/stratos.desktop \
      --replace-fail 'Exec=AppRun --no-sandbox %U' 'Exec=stratos %U'

    makeWrapper $out/lib/stratos/Stratos $out/bin/stratos \
      --set SSL_CERT_FILE "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" \
      --add-flags "--no-sandbox" \
      --prefix XDG_DATA_DIRS : "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [
        stdenv.cc.cc.lib
        pkgs.glib
        pkgs.libsecret
        pkgs.systemdMinimal
        pkgs.libGL
        pkgs.libnotify
        pkgs.libpulseaudio
        pkgs.xorg.libXScrnSaver
        pkgs.xorg.libXtst
      ]}"

    runHook postInstall
  '';

  meta = {
    description = "Multi-simulator ACARS and telemetry client for virtual airlines";
    homepage = "https://skyvexsoftware.com/";
    downloadPage = "https://skyvexsoftware.com/download";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = builtins.attrNames sources;
    mainProgram = "stratos";
  };
}
