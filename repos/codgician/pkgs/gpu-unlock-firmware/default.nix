{
  lib,
  stdenv,
  fetchurl,
  gpu-unlock,
  python3,
  zstd,
}:

# Firmware the gpu_unlock module loads from gpu-unlock/610.43.03/: stock
# Booter/GSP images extracted unchanged from NVIDIA 610.43.03, plus the
# generated V67 payloads. The generators and the module pin every file's
# SHA-256, so this follows gpu-unlock's source revision instead of carrying
# its own.
let
  nvidiaVersion = "610.43.03";
  nvidiaSource = fetchurl {
    url = "https://download.nvidia.com/XFree86/NVIDIA-kernel-module-source/NVIDIA-kernel-module-source-${nvidiaVersion}.tar.xz";
    hash = "sha256-fhGJI8eiPtw2EU1jJzpG4+BOmvmGlaQiA+esLf6fwdw=";
  };
  # Upstream extracts gsp_ga10x.bin and the NVIDIA license from this exact
  # CachyOS package.
  nvidiaUtils = fetchurl {
    url = "https://archive.cachyos.org/archive/cachyos-v3/nvidia-utils-${nvidiaVersion}-1-x86_64_v3.pkg.tar.zst";
    hash = "sha256-4X58ku7/oXiw/h9A6xekcJX4/Dzkp3vxFc9b1aTfhuk=";
  };
  nvidiaSourceRoot = "nvidia/NVIDIA-kernel-module-source-${nvidiaVersion}";
in
stdenv.mkDerivation {
  pname = "gpu-unlock-firmware";
  inherit (gpu-unlock) version src;

  nativeBuildInputs = [
    python3
    zstd
  ];

  dontConfigure = true;

  buildPhase = ''
    runHook preBuild
    mkdir nvidia
    tar -xf ${nvidiaSource} -C nvidia
    python3 firmware/generate_v67.py ${nvidiaUtils} assets
    python3 firmware/extract_boot_assets.py ${nvidiaSourceRoot} assets
    python3 firmware/extract_boot_assets.py ${nvidiaSourceRoot} assets --chip ad102
    runHook postBuild
  '';

  # Host-side suite: runs both firmware transactions against mocked hardware
  # with the generated assets and the pinned source.
  doCheck = true;
  checkPhase = ''
    runHook preCheck
    patchShebangs tests
    make test-full ASSETS="$PWD/assets" NVIDIA_SOURCE="$PWD/${nvidiaSourceRoot}"
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall
    make install-firmware ASSETS="$PWD/assets" DESTDIR="$out" \
      FWDIR=/lib/firmware/gpu-unlock/${nvidiaVersion} LICENSEDIR=/share/licenses
    runHook postInstall
  '';

  meta = {
    description = "Firmware assets for gpu-unlock, generated from the pinned NVIDIA ${nvidiaVersion} driver";
    homepage = "https://github.com/JustAResearcher/gpu-unlock-ada";
    license = with lib.licenses; [
      unfreeRedistributableFirmware
      gpl2Only
    ];
    maintainers = with lib.maintainers; [ codgician ];
    platforms = lib.platforms.linux;
    sourceProvenance = with lib.sourceTypes; [
      binaryFirmware
      fromSource
    ];
  };
}
