{
  stdenv,
  lib,
  fetchFromGitHub,
  kernel,
  quilt,
  enableDevfreq ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cix-npu-driver";
  version = "6.2.0";

  src = fetchFromGitHub {
    owner = "cixtech";
    repo = "cix_opensource__npu_driver";
    # tracking cix_mainline_dev branch
    rev = "31ee26f0b5f768d20d1fea65c2360eed7303a0a1";
    hash = "sha256-4ba2tk2c26OEjFW5TrmiMJzM+EcKso31EEhV9hRtdjw=";
  };

  hardeningDisable = [
    "pic"
    "format"
  ];
  nativeBuildInputs = kernel.moduleBuildDependencies ++ [ quilt ];

  patchPhase = ''
    runHook prePatch
    if [[ -s debian/patches/series ]]; then
      QUILT_PATCHES=debian/patches quilt push -a
    fi
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
        BUILD_NPU_DEVFREQ=${if enableDevfreq then "y" else "n"} \
        COMPASS_DRV_BTENVAR_KMD_VERSION=${finalAttrs.version}

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
})
