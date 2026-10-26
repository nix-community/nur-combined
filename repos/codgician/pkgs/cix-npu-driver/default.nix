{
  lib,
  stdenv,
  fetchFromGitHub,
  gitUpdater,
  kernel,
  kernelModuleMakeFlags,
  kmod,
}:

let
  kernelDir = "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "cix-npu-driver";
  # CIX publishes the P1 kernel 7.0 driver line as `p1_7.0_v<version>` tags;
  # the version matches upstream `version.mk`.
  version = "6.2.0";

  src = fetchFromGitHub {
    owner = "cixtech";
    repo = "cix_opensource__npu_driver";
    tag = "p1_7.0_v${finalAttrs.version}";
    hash = "sha256-n+cpnv6ZrEqKfV4emFngwwRYFmFwjJsTmM+apfmSgIQ=";
  };
  sourceRoot = "${finalAttrs.src.name}/driver";

  patches = [
    ./npu-iommu-domain.patch
  ];

  nativeBuildInputs = [ kmod ] ++ kernel.moduleBuildDependencies;

  hardeningDisable = [
    "format"
    "pic"
  ];

  # Upstream npu.mk hard-codes these env vars; reproduce them here so the
  # in-tree Makefile selects the Zhouyi v3 / Sky1 (non-Android) variant
  # used by CIX P1 hardware.
  makeFlags = kernelModuleMakeFlags ++ [
    "COMPASS_DRV_BTENVAR_KPATH=${kernelDir}"
    "COMPASS_DRV_BTENVAR_KMD_VERSION=${finalAttrs.version}"
    "BUILD_AIPU_VERSION_KMD=BUILD_ZHOUYI_V3"
    "BUILD_TARGET_PLATFORM_KMD=BUILD_PLATFORM_SKY1"
    "BUILD_NPU_DEVFREQ=y"
  ];

  # Kbuild rewrites PWD to the kernel build dir when invoked via
  # `-C ... M=...`. The `cix_mainline_dev` Makefile uses `$(PWD)` in BOTH
  # `EXTRA_CFLAGS` and the newer `ccflags-y` line; patch both, leaving the
  # outer `M=$(PWD)` recipe alone so the source-tree make still invokes the
  # kernel build correctly.
  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail '-I$(PWD)/armchina-npu/ -I$(PWD)/armchina-npu/include -I$(PWD)/armchina-npu/zhouyi' \
                     '-I$(M)/armchina-npu/ -I$(M)/armchina-npu/include -I$(M)/armchina-npu/zhouyi'
  '';

  # Install through Kbuild's `modules_install` so the kernel's signing rule
  # (kmodigest on current nixpkgs) and module compression apply; NixOS's
  # module aggregation expects the resulting per-module `.ko.cer`.
  installPhase = ''
    runHook preInstall
    make -C ${kernelDir} M=$PWD modules_install \
      ${lib.escapeShellArgs kernelModuleMakeFlags} \
      INSTALL_MOD_PATH=$out INSTALL_MOD_DIR=extra DEPMOD=true
    runHook postInstall
  '';

  passthru.updateScript = gitUpdater { rev-prefix = "p1_7.0_v"; };

  meta = {
    description = "Out-of-tree driver for the CIX P1 (Sky1) Zhouyi v3 NPU (aipu)";
    homepage = "https://github.com/cixtech/cix_opensource__npu_driver";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ codgician ];
    platforms = [ "aarch64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
