{
  stdenv,
  lib,
  fetchFromGitHub,
  kernel,
  quilt,
}:

stdenv.mkDerivation rec {
  pname = "cix-npu-driver";
  version = "6.1.0";

  src = fetchFromGitHub {
    owner = "cixtech";
    repo = "cix_opensource__npu_driver";
    rev = "193d3650645b1d3de9794aa024675c755d864d57";
    hash = "sha256-eq95TOZwG7lisyq5koSaoRK4QB+QVQcgDJj+3Ekgf2s=";
  };

  hardeningDisable = [
    "pic"
    "format"
  ];
  nativeBuildInputs = kernel.moduleBuildDependencies ++ [ quilt ];

  patchPhase = ''
    runHook prePatch
    QUILT_PATCHES=debian/patches quilt push -a
    substituteInPlace driver/Makefile \
      --replace-fail '$(PWD)' '$(src)'
    runHook postPatch
  '';

  buildPhase = ''
    runHook preBuild

    make -C "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"\
        M="$PWD/driver" \
        -j$NIX_BUILD_CORES \
        BUILD_AIPU_VERSION_KMD=BUILD_ZHOUYI_V3 \
        BUILD_TARGET_PLATFORM_KMD=BUILD_PLATFORM_SKY1 \
        BUILD_NPU_DEVFREQ=y \
        COMPASS_DRV_BTENVAR_KMD_VERSION=${version}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    make -C "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build" \
        M="$PWD/driver" \
        INSTALL_MOD_PATH="$out" \
        modules_install

    runHook postInstall
  '';

  meta = {
    description = "CIX NPU driver, Linux kernel module.";
    homepage = "https://github.com/cixtech/cix_opensource__npu_driver/tree/cix_mainline_dev";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.linux;
  };
}
