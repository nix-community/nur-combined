# Copied from https://code.thishorsie.rocks/ryze/stackpkgs/src/branch/main/packages/audiorelay.nix
{ lib
, stdenv
, fetchzip
, makeWrapper
, makeDesktopItem
, temurin-bin-17
, zip
, libglvnd
, alsa-lib
, libpulseaudio
}:
let
  manifest = ''
    Manifest-Version: 1.0
    Main-Class: com.azefsw.audioconnect.desktop.app.MainKt
    Specification-Title: Java Platform API Specification
    Specification-Version: 17
    Specification-Vendor: Oracle Corporation
    Implementation-Title: Java Runtime Environment
    Implementation-Version: 17.0.6
    Implementation-Vendor: Eclipse Adoptium
    Created-By: 17.0.5 (Eclipse Adoptium)
  '';

  runtimeLibs = [
    libglvnd
    alsa-lib
    libpulseaudio
    stdenv.cc.cc.lib
  ];

  desktopItem = makeDesktopItem {
    name = "audiorelay";

    desktopName = "AudioRelay";
    comment = "Stream audio between your devices";
    categories = [ "AudioVideo" "Audio" "Network" ];
    icon = "audiorelay";
    exec = "audiorelay";

    startupNotify = true;
    startupWMClass = "com-azefsw-audioconnect-desktop-app-MainKt";
  };
in
stdenv.mkDerivation {
  pname = "audiorelay";
  version = "0.27.5";

  src = fetchzip {
    url = "https://dl.audiorelay.net/setups/linux/audiorelay-0.27.5.tar.gz";
    hash = "sha256-KfhAimDIkwYYUbEcgrhvN5DGHg8DpAHfGkibN1Ny4II=";
    stripRoot = false;
  };

  nativeBuildInputs = [
    makeWrapper
    zip
  ];

  # Patch the jar with manifest with main class to use it unwrapped
  patchPhase = ''
    mkdir META-INF
    echo '${manifest}' > META-INF/MANIFEST.MF
    zip -r lib/app/audiorelay.jar META-INF/MANIFEST.MF
  '';

  installPhase = ''
    runHook preInstall

    install -Dm644 ${desktopItem}/share/applications/audiorelay.desktop $out/share/applications/audiorelay.desktop
    install -Dm644 lib/AudioRelay.png $out/share/pixmaps/audiorelay.png
    install -Dm644 lib/app/audiorelay.jar $out/share/audiorelay/audiorelay.jar

    # Can't use from pkgs since these ones are older and newer fails to load some symbols
    install -D lib/runtime/lib/libnative-rtaudio.so $out/lib/libnative-rtaudio.so
    install -D lib/runtime/lib/libnative-opus.so $out/lib/libnative-opus.so

    makeWrapper ${temurin-bin-17}/bin/java $out/bin/audiorelay \
      --add-flags "-jar $out/share/audiorelay/audiorelay.jar" \
      --prefix LD_LIBRARY_PATH : $out/lib/ \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibs} \
      --unset NIXOS_OZONE_WL \
      --set DISPLAY :0

    runHook postInstall
  '';

  meta = {
    description = "Application to stream every sound from your PC to one or multiple Android devices";
    homepage = "https://audiorelay.net";
    downloadPage = "https://audiorelay.net/downloads";
    license = lib.licenses.unfree;

    sourceProvenance = with lib.sourceTypes; [
      binaryBytecode
      binaryNativeCode # native rtaudio and opus libs
    ];
  };
}
