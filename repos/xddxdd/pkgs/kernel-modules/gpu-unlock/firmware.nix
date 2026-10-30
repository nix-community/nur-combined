{
  fetchurl,
  lib,
  linkFarm,
  python3,
  src,
  stdenv,
  version,
  zstd,
}:
let
  artifacts = lib.importJSON ./artifacts.json;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "gpu-unlock-firmware";
  inherit src version;
  __structuredAttrs = true;
  strictDeps = true;

  nativeBuildInputs = [
    python3
    zstd
  ];
  dontConfigure = true;
  dontPatchELF = true;
  dontStrip = true;
  makeFlags = [
    "INPUTS=${
      linkFarm "gpu-unlock-inputs" (
        map (artifact: {
          name = artifact.filename;
          path = fetchurl {
            inherit (artifact) url sha256;
          };
        }) artifacts
      )
    }"
    "ASSETS=$(CURDIR)/assets"
    "FWDIR=${placeholder "out"}/lib/firmware/gpu-unlock/${lib.removeSuffix ".tar.xz" (lib.removePrefix "NVIDIA-kernel-module-source-" (builtins.head artifacts).filename)}"
    "LICENSEDIR=${placeholder "out"}/share/licenses"
    "PKG=${finalAttrs.pname}"
  ];
  buildFlags = [ "firmware" ];
  installTargets = [
    "install-firmware"
    "install-licenses"
  ];

  meta = {
    description = "Pinned NVIDIA firmware assets for gpu-unlock";
    homepage = "https://github.com/Zagitta/gpu-unlock";
    license = [
      lib.licenses.unfree
      lib.licenses.gpl2Only
    ];
    sourceProvenance = [ lib.sourceTypes.binaryFirmware ];
    maintainers = [ lib.maintainers.xddxdd ];
    platforms = [ "x86_64-linux" ];
    hydraPlatforms = [ ];
  };
})
