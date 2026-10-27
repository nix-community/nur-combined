{
  callPackage,
  fetchFromGitHub,
  kernel,
  lib,
  stdenv,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "gpu-unlock";
  version = "0-unstable-2026-10-26";
  src = fetchFromGitHub {
    owner = "Zagitta";
    repo = "gpu-unlock";
    rev = "6081407b312aa3139a2bed62bdda354f4ffddc1d";
    hash = "sha256-6FbsBw20/+MRP676qur+C4glwrKmqlNi3xwAzB82zoA=";
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
