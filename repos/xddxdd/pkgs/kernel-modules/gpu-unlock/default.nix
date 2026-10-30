{
  callPackage,
  fetchFromGitHub,
  kernel,
  lib,
  stdenv,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "gpu-unlock";
  version = "unraid-unstable-2026-10-28";
  src = fetchFromGitHub {
    owner = "Zagitta";
    repo = "gpu-unlock";
    rev = "7eb51bccae0a0b7e599e084d971170e9a1e82d0c";
    hash = "sha256-1KD/J1S1uyI5GGoTwQ1cU/sXeEKlG54exSvi6U+j73M=";
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
