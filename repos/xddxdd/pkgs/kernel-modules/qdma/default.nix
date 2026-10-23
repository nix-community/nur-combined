{
  lib,
  stdenv,
  fetchFromGitHub,
  bash,
  unstableGitUpdater,
  kernel,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qdma";
  version = "0-unstable-2026-10-22";

  src = fetchFromGitHub {
    owner = "Xilinx";
    repo = "dma_ip_drivers";
    rev = "a918c5196a09f95756af244a607d543d9dce5bfb";
    hash = "sha256-cT9mtfXXuE6c37wpqHxfYLzwNmqhhbuThLRbSR/l3PY=";
  };
  __structuredAttrs = true;
  strictDeps = true;

  postPatch = ''
    substituteInPlace QDMA/linux-kernel/driver/Makefile \
      QDMA/linux-kernel/driver/src/Makefile \
      --replace-fail 'SHELL = /bin/bash' 'SHELL = ${bash}/bin/bash'
  '';

  preConfigure = "cd QDMA/linux-kernel/driver";

  makeFlags = (kernel.commonMakeFlags or kernel.makeFlags) ++ [
    "KSRC=${kernel.dev}/lib/modules/${kernel.modDirVersion}/source"
    "KOBJ=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "modulesymfile=Module.symvers"
  ];
  env.CPPFLAGS =
    "-Wno-error=format-truncation -Wno-error=unused-but-set-variable -Wno-error=unused-but-set-parameter"
    + lib.optionalString (builtins.elem "LLVM=1" (
      kernel.commonMakeFlags or kernel.makeFlags or [ ]
    )) " -Wno-error=parentheses-equality";
  buildFlags = [
    "mod_pf"
    "mod_vf"
  ];

  hardeningDisable = [
    "pic"
    "format"
  ];
  nativeBuildInputs = kernel.moduleBuildDependencies;
  dontPatchELF = true;

  installPhase = ''
    runHook preInstall
    moduleDir="$out/lib/modules/${kernel.modDirVersion}/extra"
    install -Dm644 ../bin/qdma-pf.ko "$moduleDir/qdma-pf.ko"
    install -Dm644 ../bin/qdma-vf.ko "$moduleDir/qdma-vf.ko"
    runHook postInstall
  '';

  passthru = {
    inherit kernel;
    updateScript = unstableGitUpdater {
      url = "https://github.com/Xilinx/dma_ip_drivers";
      hardcodeZeroVersion = true;
    };
    moduleNames = [
      "qdma-pf"
      "qdma-vf"
    ];
  };

  meta = {
    description = "Xilinx QDMA PCIe kernel modules";
    homepage = "https://github.com/Xilinx/dma_ip_drivers";
    license = lib.licenses.gpl2Only;
    platforms = [ "x86_64-linux" ];
    maintainers = with lib.maintainers; [ xddxdd ];
  };
})
