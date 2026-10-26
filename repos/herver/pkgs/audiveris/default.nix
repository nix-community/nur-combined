{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  pkgs,
}:

let
  version = "5.11.0";
  pname = "audiveris";

  src = fetchurl {
    url = "https://github.com/Audiveris/audiveris/releases/download/${version}/Audiveris-${version}-ubuntu24.04-x86_64.deb";
    hash = "sha256-8gETqqM7MUnsjWoJsqeWM2DmX6/ZLWk4mYeoW7w+x6M=";
  };

  # Libraries for the bundled JRE (AWT/X11, sound) and for the JavaCPP natives
  # (Tesseract, Leptonica) that are extracted from the jars at runtime and
  # therefore never seen by autoPatchelfHook.
  runtimeLibs = with pkgs; [
    alsa-lib
    freetype
    fontconfig
    libGL
    stdenv.cc.cc.lib
    libx11
    libxext
    libxi
    libxrender
    libxtst
    libxxf86vm
    # loaded through JNA at startup
    glib
    gtk3
  ];
in
stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = runtimeLibs;

  # CRIU support in the bundled runtime is optional and unused.
  autoPatchelfIgnoreMissingDeps = [
    "libnet.so.1"
    "libnl-3.so.200"
    "libprotobuf-c.so.1"
  ];

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    dpkg-deb -x $src .

    mkdir -p $out/bin $out/share/applications $out/share/icons/hicolor/256x256/apps
    cp -r opt/audiveris $out/lib

    install -m644 $out/lib/lib/audiveris-Audiveris.desktop $out/share/applications/audiveris.desktop
    substituteInPlace $out/share/applications/audiveris.desktop \
      --replace-fail 'Exec=/opt/audiveris/bin/Audiveris' 'Exec=audiveris %f' \
      --replace-fail 'Icon=/opt/audiveris/lib/Audiveris.png' 'Icon=audiveris' \
      --replace-fail 'Categories=Unknown' 'Categories=AudioVideo;Audio;Graphics;'
    ln -s $out/lib/lib/Audiveris.png $out/share/icons/hicolor/256x256/apps/audiveris.png

    makeWrapper $out/lib/bin/Audiveris $out/bin/audiveris \
      --set SSL_CERT_FILE "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibs}"

    runHook postInstall
  '';

  meta = {
    description = "Open-source Optical Music Recognition (OMR) engine";
    homepage = "https://audiveris.github.io/audiveris/";
    downloadPage = "https://github.com/Audiveris/audiveris/releases";
    changelog = "https://github.com/Audiveris/audiveris/releases/tag/${version}";
    license = lib.licenses.agpl3Plus;
    sourceProvenance = with lib.sourceTypes; [
      binaryNativeCode
      binaryBytecode
    ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "audiveris";
  };
}
