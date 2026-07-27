{
  sources,

  lib,
  stdenv,

  autoPatchelfHook,
  dotnetCorePackages,
  glib,
  icu,
  libGL,
  libdecor,
  libdrm,
  libgbm,
  libsndfile,
  libx11,
  libxcursor,
  libxi,
  libxinerama,
  libxkbcommon,
  libxrandr,
  libxscrnsaver,
  libxxf86vm,
  makeWrapper,
  openal,
  openssl,
  unzip,
  wayland,
}:
stdenv.mkDerivation {
  inherit (sources.helion-bin) pname version src;
  sourceRoot = ".";

  nativeBuildInputs = [
    autoPatchelfHook
    unzip
    makeWrapper
  ];

  buildInputs = [
    glib
    libGL
    libdecor
    libdrm
    libgbm
    libsndfile
    libx11
    libxcursor
    libxi
    libxinerama
    libxkbcommon
    libxrandr
    libxscrnsaver
    libxxf86vm
    openal
    openssl
    stdenv.cc.cc.lib
    wayland
  ];

  runtimeDependencies = [
    icu
  ];

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/{bin,libexec}
    cp -r * $out/libexec

    makeWrapper $out/libexec/Helion $out/bin/Helion \
      --set DOTNET_ROOT ${dotnetCorePackages.dotnet_9.runtime}/share/dotnet

    patchelf $out/libexec/Helion \
      --add-needed libopenal.so.1 \
      --add-needed libGL.so \
      --add-needed libssl.so

    runHook postBuild
  '';

  meta = {
    description = "A modern fast paced Doom FPS engine";
    homepage = "https://github.com/Helion-Engine/Helion";
    license = lib.licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "Helion";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
