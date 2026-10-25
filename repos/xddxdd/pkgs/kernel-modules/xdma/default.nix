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
  version = "0-unstable-2026-10-22";

  src = fetchFromGitHub {
    owner = "Xilinx";
    repo = "dma_ip_drivers";
    rev = "a918c5196a09f95756af244a607d543d9dce5bfb";
    hash = "sha256-cT9mtfXXuE6c37wpqHxfYLzwNmqhhbuThLRbSR/l3PY=";
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
  env.INSTALL_MOD_PATH = placeholder "out";
  env.INSTALL_MOD_DIR = "extra";

  makeFlags = kernel.commonMakeFlags or kernel.makeFlags;

  installTargets = [ "modules_install" ];
  preBuild = ''
    makeFlagsArray+=("-C" "${finalAttrs.env.KSRC}" "M=$(pwd)")
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
