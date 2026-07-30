{ lib
, stdenv
, appimageTools
, fetchurl
, makeDesktopItem
, makeWrapper
, autoPatchelfHook
, nix-update-script
, alsa-lib
, at-spi2-atk
, at-spi2-core
, atk
, cairo
, cups
, dbus
, expat
, glib
, gtk3
, libxkbcommon
, mesa
, nspr
, nss
, pango
, systemd
, libX11
, libXcomposite
, libXdamage
, libXext
, libXfixes
, libXrandr
, libxcb
, libdbusmenu-gtk2
, libdbusmenu
, gtk2
, dbus-glib
, musl
, libsecret
}:

let
  pname = "tabby";
  version = "1.0.235";

  src = fetchurl {
    url = "https://github.com/Eugeny/tabby/releases/download/v${version}/tabby-${version}-linux-x64.AppImage";
    hash = "sha256-DKXcAV/l7nhA8rIGhkzDfFL3w2t6c06GU6Oa6KV23O8=";
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };

  desktopItem = makeDesktopItem {
    name = pname;
    exec = "${pname} --no-sandbox %U";
    icon = pname;
    desktopName = "Tabby";
    comment = "A terminal for a modern age";
    categories = [ "System" "TerminalEmulator" "Utility" ];
    startupWMClass = "tabby";
    mimeTypes = [
      "x-scheme-handler/tabby"
    ];
  };
in
stdenv.mkDerivation {
  inherit pname version;

  src = appimageContents;

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    glib
    gtk3
    libxkbcommon
    mesa
    nspr
    nss
    pango
    stdenv.cc.cc.lib
    systemd
    libX11
    libXcomposite
    libXdamage
    libXext
    libXfixes
    libXrandr
    libxcb
    libdbusmenu-gtk2
    libdbusmenu
    gtk2
    dbus-glib
    musl
    libsecret
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/tabby $out/bin
    cp -r . $out/opt/tabby

    makeWrapper $out/opt/tabby/tabby $out/bin/tabby \
      --add-flags "--no-sandbox"

    install -m 444 -D ${desktopItem}/share/applications/${pname}.desktop \
      $out/share/applications/${pname}.desktop

    install -m 444 -D $out/opt/tabby/usr/share/icons/hicolor/256x256/apps/tabby.png \
      $out/share/icons/hicolor/256x256/apps/${pname}.png

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "A terminal for a more modern age";
    homepage = "https://github.com/Eugeny/tabby";
    license = licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "tabby";
  };
}
