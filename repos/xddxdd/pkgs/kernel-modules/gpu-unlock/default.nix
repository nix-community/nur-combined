{
  callPackage,
  fetchFromGitHub,
  kernel,
  lib,
  stdenv,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "gpu-unlock";
  version = "unraid-unstable-2026-10-27";
  src = fetchFromGitHub {
    owner = "Zagitta";
    repo = "gpu-unlock";
    rev = "1fc6d628c49c7fba34ef3a2e7f758700d35ce890";
    hash = "sha256-E2fmxMc5nq0Jg+J+BVhIihaAoC8ay01DefHxmsa2uiM=";
  };
  __structuredAttrs = true;
  strictDeps = true;

  sourceRoot = "source/kernel/gpu_unlock";
  hardeningDisable = [
    "pic"
    "format"
  ];
  nativeBuildInputs = kernel.moduleBuildDependencies;
  env.KSRC = "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build";
  env.INSTALL_MOD_PATH = placeholder "out";
  makeFlags = kernel.commonMakeFlags or kernel.makeFlags;
  preBuild = ''
    makeFlagsArray+=("-C" "${finalAttrs.env.KSRC}" "M=$(pwd)")
  '';
  installTargets = [ "modules_install" ];

  passthru.firmware = callPackage ./firmware.nix { inherit (finalAttrs) src version; };
  passthru.updateScript = [ (toString ./update.sh) ];

  meta = {
    description = "Early-boot Ampere GPU floating-point instruction rate unlock";
    homepage = "https://github.com/Zagitta/gpu-unlock";
    license = lib.licenses.gpl2Only;
    maintainers = [ lib.maintainers.xddxdd ];
    platforms = [ "x86_64-linux" ];
  };
})
