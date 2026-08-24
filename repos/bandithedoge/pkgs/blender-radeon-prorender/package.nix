{
  blenderVersion ? lib.versions.majorMinor blender.version,

  fetchzip,
  lib,
  stdenv,
  writeScript,

  autoPatchelfHook,
  blender,
  libGL,
  rocmPackages,
  vulkan-loader,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "blender-radeon-prorender";
  version = "3.6.11";
  src = fetchzip {
    url = "https://github.com/GPUOpen-LibrariesAndSDKs/RadeonProRenderBlenderAddon/releases/download/v3.6.11/RadeonProRenderForBlender_3.6.11_Ubuntu24-325eb7f-linux.zip";
    hash = "sha256-tfsyG9vXPRDZdVk42/BbBG/RH4q0upzKcnCs25cELEU=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    libGL
    rocmPackages.clr
    stdenv.cc.cc.lib
    vulkan-loader
  ];

  buildPhase = ''
    runHook preBuild

    path=$out/share/blender/${blenderVersion}/scripts/addons/rprblender
    mkdir -p $path
    cp -r * $path

    runHook postBuild
  '';

  passthru.updateScript = writeScript "update-blender-radeon-prorender" ''
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash -p curl pcre2 common-updater-scripts jq

    release="$(curl -s https://api.github.com/repos/GPUOpen-LibrariesAndSDKs/RadeonProRenderBlenderAddon/releases/latest)"
    version="$(echo $release | jq -r '.tag_name | scan("v(.*)") | .[0]')"
    url="$(echo $release | jq -r '.assets | map(select(.name | test("Ubuntu"))) | .[0] | .browser_download_url')"
    update-source-version "$UPDATE_NIX_ATTR_PATH" "$version" "" "$url"
  '';

  meta = {
    description = "This hardware-agnostic rendering plug-in for Blender uses accurate ray-tracing technology to produce images and animations of your scenes, and provides real-time interactive rendering and continuous adjustment of effects";
    homepage = "https://www.amd.com/en/products/graphics/software/radeon-prorender/blender.html";
    license = lib.licenses.asl20;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
