{
  callPackage,
  fetchFromGitHub,
  kernel,
  kmod,
  lib,
  stdenv,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "gpu-unlock";
  version = "0-unstable-2026-10-24";
  src = fetchFromGitHub {
    owner = "Zagitta";
    repo = "gpu-unlock";
    rev = "af28cbbfd3d922a659227ecfb7369adfd924cf03";
    hash = "sha256-6FaDuPojB707ds7gkQY/g/+m4Tnz1xHZ95UjNfFxBJc=";
  };
  __structuredAttrs = true;
  strictDeps = true;

  sourceRoot = "source/kernel/gpu_unlock";
  hardeningDisable = [
    "pic"
    "format"
  ];
  nativeBuildInputs = kernel.moduleBuildDependencies;
  nativeInstallCheckInputs = [ kmod ];
  env.KSRC = "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build";
  env.INSTALL_MOD_PATH = placeholder "out";
  makeFlags = kernel.commonMakeFlags or kernel.makeFlags;
  preBuild = ''
    makeFlagsArray+=("-C" "${finalAttrs.env.KSRC}" "M=$(pwd)")
  '';
  installTargets = [ "modules_install" ];

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    module=$(find "$out/lib/modules/${kernel.modDirVersion}" -name 'gpu_unlock.ko*' -type f)
    test -n "$module"
    test "$(modinfo -F name "$module")" = gpu_unlock
    modinfo -F vermagic "$module" | grep -F '${kernel.modDirVersion} '
    test "$(modinfo -F firmware "$module" | wc -l)" -eq 5
    runHook postInstallCheck
  '';

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
