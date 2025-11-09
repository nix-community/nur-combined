{
  sources,
  lib,
  stdenv,
  autoPatchelfHook,
  buildFHSEnv,
  copyDesktopItems,
  makeDesktopItem,
  makeWrapper,
  # Dependencies
  fontconfig,
  freetype,
  glib,
  mesa-demos,
  libglvnd,
  openal,
  xorg,
  zlib,
}:
let
  distPackage = stdenv.mkDerivation {
    inherit (sources.unigine-superposition) pname version src;

    nativeBuildInputs = [
      autoPatchelfHook
      makeWrapper
    ];
    buildInputs = libraries;

    unpackPhase = ''
      runHook preUnpack

      sh "$src" --noexec --nox11 --target "$(pwd)"

      runHook postUnpack
    '';

    buildPhase = ''
      runHook preBuild

      rm -f bin/libopenal.so
      rm -f bin/qt/lib/libQt5QuickTest.so.5
      patchelf --replace-needed libcrypto.so.1.0.0 libcrypto.so bin/qt/lib/libssl.so

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -r * $out/
      rm -f $out/env-vars

      autoPatchelf $out/bin/qt

      runHook postInstall
    '';

    dontFixup = true;
    dontWrapQtApps = true;
    dontAutoPatchelf = true;
  };

  libraries = [
    fontconfig
    freetype
    glib
    mesa-demos
    libglvnd
    openal
    stdenv.cc.cc.lib
    xorg.libICE
    xorg.libSM
    xorg.libX11
    xorg.libXau
    xorg.libxcb
    xorg.libXcursor
    xorg.libXdmcp
    xorg.libXext
    xorg.libXi
    xorg.libXinerama
    xorg.libXrandr
    xorg.libXrender
    zlib
  ];

  fhs = buildFHSEnv {
    name = "unigine-superposition";
    targetPkgs = _pkgs: libraries;
    runScript = "${distPackage}/Superposition";
    unshareUser = false;
    unshareIpc = false;
    unsharePid = false;
    unshareNet = false;
    unshareUts = false;
    unshareCgroup = false;
  };
in
stdenv.mkDerivation (finalAttrs: {
  inherit (sources.unigine-superposition) pname version;

  dontUnpack = true;

  nativeBuildInputs = [ copyDesktopItems ];

  postInstall = ''
    install -Dm755 ${fhs}/bin/unigine-superposition $out/bin/unigine-superposition

    for SIZE in 16 24 32 48 64 128 256; do
        install -Dm644 ${distPackage}/icons/superposition_icon_''${SIZE}.png "$out/share/icons/hicolor/''${SIZE}x''${SIZE}/apps/unigine-superposition.png"
    done
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "unigine-superposition";
      exec = "unigine-superposition";
      desktopName = "Unigine Superposition";
      genericName = finalAttrs.meta.description;
      icon = "unigine-superposition";
      categories = [
        "Game"
        "Utility"
      ];
      terminal = false;
    })
  ];

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Extreme performance and stability test for PC hardware: video card, power supply, cooling system";
    homepage = "https://benchmark.unigine.com/superposition";
    platforms = [ "x86_64-linux" ];
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    mainProgram = "unigine-superposition";
  };
})
