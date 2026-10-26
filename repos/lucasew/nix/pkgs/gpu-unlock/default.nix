{
  lib,
  stdenv,
  stdenvNoCC,
  fetchFromGitHub,
  fetchurl,
  python3,
  xz,
  zstd,
  kernel,
  kernelModuleMakeFlags,
  kmod,
}:

let
  version = "1.0.0";
  # Upstream has no tags. This rev is main after the GA106M 0x2560 id.
  rev = "990a14e9b7dc8eaad8e6925133aa0e8382efe6cf";

  src = fetchFromGitHub {
    owner = "Zagitta";
    repo = "gpu-unlock";
    inherit rev;
    hash = "sha256-mSwqkpNoXJ+f6B4MVhHfYl9u2gFwU07Z+7eAPCwrcho=";
  };

  # Pinned by firmware/artifacts-610.43.03.json. The generators refuse any
  # other bytes, so these hashes are the upstream pin, not a guess.
  nvSource = fetchurl {
    url = "https://download.nvidia.com/XFree86/NVIDIA-kernel-module-source/NVIDIA-kernel-module-source-610.43.03.tar.xz";
    hash = "sha256-fhGJI8eiPtw2EU1jJzpG4+BOmvmGlaQiA+esLf6fwdw=";
  };
  nvUtils = fetchurl {
    url = "https://archive.cachyos.org/archive/cachyos-v3/nvidia-utils-610.43.03-1-x86_64_v3.pkg.tar.zst";
    hash = "sha256-4X58ku7/oXiw/h9A6xekcJX4/Dzkp3vxFc9b1aTfhuk=";
  };

  firmware = stdenvNoCC.mkDerivation {
    pname = "gpu-unlock-firmware";
    inherit version src;

    nativeBuildInputs = [
      python3
      xz
      zstd
    ];

    dontConfigure = true;
    # gsp_ga10x.bin is an 80 MiB firmware blob. strip and patchelf must not touch it.
    dontStrip = true;
    dontPatchELF = true;

    buildPhase = ''
      runHook preBuild
      mkdir -p assets.src assets
      tar -xf ${lib.escapeShellArg nvSource} -C assets.src
      python3 firmware/generate_v67.py ${lib.escapeShellArg nvUtils} assets
      python3 firmware/extract_boot_assets.py \
        assets.src/NVIDIA-kernel-module-source-610.43.03 \
        assets
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      fw=$out/lib/firmware/gpu-unlock/610.43.03
      mkdir -p "$fw" "$out/share/licenses/gpu-unlock-firmware"
      install -m644 \
        assets/booter_load_ga102.bin \
        assets/gsp_ga10x.bin \
        assets/gsp_boot_ga102.bin \
        assets/gsp_boot_desc_ga102.bin \
        assets/v67-ga102-610.43.03.bin \
        "$fw"
      install -m644 assets/NVIDIA-LICENSE \
        "$out/share/licenses/gpu-unlock-firmware/NVIDIA-LICENSE"
      install -m644 firmware/NOTICE.md \
        "$out/share/licenses/gpu-unlock-firmware/NOTICE.md"
      runHook postInstall
    '';

    meta = {
      description = "GSP and V67 firmware gpu-unlock loads before the NVIDIA driver binds";
      homepage = "https://github.com/Zagitta/gpu-unlock";
      license = lib.licenses.unfree;
      platforms = [ "x86_64-linux" ];
      sourceProvenance = with lib.sourceTypes; [ binaryFirmware ];
    };
  };
in
stdenv.mkDerivation {
  pname = "gpu-unlock";
  version = "${version}-${kernel.version}";
  inherit src;

  nativeBuildInputs = [ kmod ] ++ kernel.moduleBuildDependencies;

  hardeningDisable = [
    "format"
    "pic"
  ];

  # patchelf rejects a relocatable .ko. MODULE_FIRMWARE stays in .modinfo.
  dontPatchELF = true;

  # DWARF names kernel headers under kernel.dev, and that output depends on
  # rustc, gcc, and python. strip -S drops the DWARF and keeps .modinfo.
  disallowedRequisites = [ kernel.dev ];

  makeFlags = kernelModuleMakeFlags ++ [
    "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  preBuild = ''
    cd kernel/gpu_unlock
  '';

  installPhase = ''
    runHook preInstall
    install -D gpu_unlock.ko $out/lib/modules/${kernel.modDirVersion}/extra/gpu_unlock.ko
    runHook postInstall
  '';

  postFixup = ''
    ko=$out/lib/modules/${kernel.modDirVersion}/extra/gpu_unlock.ko
    modinfo -F firmware "$ko" | grep -qx 'gpu-unlock/610.43.03/gsp_ga10x.bin'
  '';

  passthru = {
    inherit firmware;
  };

  meta = {
    description = "Unlock Ampere GeForce FP16/BF16 issue rate before the NVIDIA driver binds";
    homepage = "https://github.com/Zagitta/gpu-unlock";
    license = lib.licenses.gpl2Only;
    platforms = [ "x86_64-linux" ];
  };
}
