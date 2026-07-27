{
  sources,

  lib,
  stdenv,

  autoPatchelfHook,
  blender,
  libGL,
  rocmPackages,
  vulkan-loader,
}:
stdenv.mkDerivation {
  inherit (sources.blender-radeon-prorender) pname src;
  version = lib.removePrefix "v" (
    builtins.elemAt (lib.splitString "/" sources.blender-radeon-prorender.version) 0
  );

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    libGL
    rocmPackages.clr
    stdenv.cc.cc.lib
    vulkan-loader
  ];

  buildPhase = ''
    runHook preBuild

    path=$out/share/blender/${lib.versions.majorMinor blender.version}/scripts/addons/rprblender
    mkdir -p $path
    cp -r * $path

    runHook postBuild
  '';

  meta = {
    description = "This hardware-agnostic rendering plug-in for Blender uses accurate ray-tracing technology to produce images and animations of your scenes, and provides real-time interactive rendering and continuous adjustment of effects";
    homepage = "https://www.amd.com/en/products/graphics/software/radeon-prorender/blender.html";
    license = lib.licenses.asl20;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
