{
  fetchzip,
  lib,
  nix-update-script,
  stdenv,

  autoPatchelfHook,
  dotnetCorePackages,
  glib,
  icu,
  libGL,
  libdecor,
  libdrm,
  libgbm,
  libjack2,
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
  portaudio,
  unzip,
  wayland,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "helion-bin";
  version = "1.1.0.0";
  src = fetchzip {
    url = "https://github.com/Helion-Engine/Helion/releases/download/${finalAttrs.version}/Helion-${finalAttrs.version}-linux-x64_AOT.zip";
    sha256 = "sha256-rmveRTgqi7y2qTKk1Mhbh0hw6z17aFfr1S51a3SYSTs=";
    stripRoot = false;
  };

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
    libjack2
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
    portaudio
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

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "A modern fast paced Doom FPS engine";
    homepage = "https://github.com/Helion-Engine/Helion";
    license = lib.licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "Helion";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
