{
  sources,

  lib,
  stdenv,

  alsa-lib,
  autoPatchelfHook,
  libxkbcommon,
  lilv,
  vulkan-loader,
  wayland,
}:
let
  source =
    if stdenv.targetPlatform.isAarch64 then sources.yadaw-bin-aarch64 else sources.yadaw-bin-x86_64;
in
stdenv.mkDerivation {
  inherit (source) pname version src;

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    alsa-lib
    libxkbcommon
    lilv
    stdenv.cc.cc.lib
    vulkan-loader
    wayland
  ];

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/bin
    patchelf \
      --add-needed libvulkan.so \
      --add-needed libwayland-client.so \
      --add-needed libxkbcommon.so \
      yadaw
    cp yadaw $out/bin

    runHook postBuild
  '';

  meta = {
    description = "Sfx creation tool and midi player that doesn't crash often";
    homepage = "https://github.com/mlm-games/yadaw";
    license = lib.licenses.agpl3Plus;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "yadaw";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
