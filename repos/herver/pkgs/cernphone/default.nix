{
  lib,
  stdenv,
  fetchurl,
  appimageTools,
  autoPatchelfHook,
  makeWrapper,
  pkgs,
}:

let
  version = "1.3.3";
  pname = "cernphone";

  src = fetchurl {
    url = "https://cernphone-sw.web.cern.ch/cernphone-sw/releases/cern-phone-app-${version}-x86_64-linux.AppImage.d/cern-phone-app.AppImage";
    # sha512 published by upstream in releases/latest-linux.yml
    hash = "sha512-oYczcdd2v86awZRmEVe3J72JB1smfRs+XhhDcBUCzRsFK8O2B5zEhdC1luPjhKQyitElpRT13foydiPemGRh7A==";
    name = "cern-phone-app-${version}.AppImage";
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };
in
stdenv.mkDerivation {
  inherit pname version;

  src = appimageContents;

  nativeBuildInputs = [
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
    xorg.libX11
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrandr
    xorg.libxcb
    xorg.libxshmfence
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib/cernphone $out/share/applications
    # Skip AppRun and usr/ (bundled legacy libs like libgconf are not needed by Electron)
    cp -r locales resources *.pak *.bin *.dat *.so *.so.1 *.json \
      chrome_crashpad_handler cern-phone-app $out/lib/cernphone/
    cp -r usr/share/icons $out/share/

    cp cern-phone-app.desktop $out/share/applications/cernphone.desktop
    substituteInPlace $out/share/applications/cernphone.desktop \
      --replace-fail 'Exec=AppRun --no-sandbox %U' 'Exec=cernphone %U'

    makeWrapper $out/lib/cernphone/cern-phone-app $out/bin/cernphone \
      --set SSL_CERT_FILE "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" \
      --add-flags "--no-sandbox" \
      --prefix XDG_DATA_DIRS : "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [
        # dlopened by native node modules packed inside app.asar
        # (keytar: libsecret/glib; node-hid: libusb/libudev)
        pkgs.glib
        pkgs.libsecret
        pkgs.libusb1
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
    description = "CERNphone desktop softphone client for the CERN telephony service";
    homepage = "https://cernphone.docs.cern.ch/";
    downloadPage = "https://cernphone-sw.web.cern.ch/cernphone-sw/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "cernphone";
  };
}
