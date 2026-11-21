{
  lib,
  stdenv,
  stdenvNoCC,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  wrapGAppsHook3,
  cairo,
  dbus,
  gdk-pixbuf,
  glib,
  glib-networking,
  gsettings-desktop-schemas,
  gtk3,
  libpulseaudio,
  libsoup_3,
  openssl,
  pipewire,
  webkitgtk_4_1,
}:
let
  release = lib.importJSON ./versions.json;
in
stdenvNoCC.mkDerivation {
  pname = "splitwave-bin";
  inherit (release) version;

  src = fetchurl {
    inherit (release) url hash;
  };

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    wrapGAppsHook3
  ];

  buildInputs = [
    cairo
    dbus
    gdk-pixbuf
    glib
    glib-networking
    gsettings-desktop-schemas
    gtk3
    libpulseaudio
    libsoup_3
    openssl
    pipewire
    stdenv.cc.cc.lib
    webkitgtk_4_1
  ];

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb --extract "$src" .
    runHook postUnpack
  '';

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    cp -r usr/bin usr/share "$out/"
    runHook postInstall
  '';

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Node-based audio routing and effects application";
    homepage = "https://github.com/Horuse/Splitwave";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "splitwave";
    platforms = [ "x86_64-linux" ];
  };
}
