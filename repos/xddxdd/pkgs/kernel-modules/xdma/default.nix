{
  lib,
  stdenv,
  fetchFromGitHub,
  bash,
  unstableGitUpdater,
  kernel,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xdma";
  version = "0-unstable-2026-08-20";

  src = fetchFromGitHub {
    owner = "Xilinx";
    repo = "dma_ip_drivers";
    rev = "b8466090b4e812e191da9e9305ffb11cb7ace768";
    hash = "sha256-az23GPWf3wfMhMK4dR89o1hZAHkCMCgdrmnGakxLwBo=";
  };
  __structuredAttrs = true;
  strictDeps = true;

  patches = [ ./xdma-kbuild-ccflags.patch ];

  postPatch = ''
    substituteInPlace XDMA/linux-kernel/xdma/Makefile \
      --replace-fail 'SHELL = /bin/bash' 'SHELL = ${bash}/bin/bash'
  '';

  preConfigure = "cd XDMA/linux-kernel/xdma";

  env.KSRC = "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build";

  makeFlags = kernel.commonMakeFlags or kernel.makeFlags;
  preBuild = ''
    makeFlagsArray+=("-C" "${finalAttrs.env.KSRC}" "M=$(pwd)")
  '';

  installPhase = ''
    runHook preInstall
    install -Dm644 xdma.ko "$out/lib/modules/${kernel.modDirVersion}/extra/xdma.ko"
    runHook postInstall
  '';

  hardeningDisable = [
    "pic"
    "format"
  ];
  nativeBuildInputs = kernel.moduleBuildDependencies;
  dontPatchELF = true;

  passthru = {
    inherit kernel;
    updateScript = unstableGitUpdater {
      url = "https://github.com/Xilinx/dma_ip_drivers";
      hardcodeZeroVersion = true;
    };
    moduleNames = [ "xdma" ];
  };

  meta = {
    description = "Xilinx XDMA PCIe kernel module";
    homepage = "https://github.com/Xilinx/dma_ip_drivers";
    license = lib.licenses.gpl2Only;
    platforms = [ "x86_64-linux" ];
    maintainers = with lib.maintainers; [ xddxdd ];
  };
})
