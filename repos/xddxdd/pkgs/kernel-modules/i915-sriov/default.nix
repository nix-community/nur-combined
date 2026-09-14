{
  fetchFromGitHub,
  unstableGitUpdater,
  stdenv,
  lib,
  kernel,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "i915-sriov";
  version = "2026.09.14-unstable-2026-09-14";
  src = fetchFromGitHub {
    owner = "strongtz";
    repo = "i915-sriov-dkms";
    rev = "507fe9eb1f177b002f644cfd7e87cd211a12f021";
    hash = "sha256-z5KY5tRg1cI5wfR7xo8jUKgGBN2T9OcrbfUabfreeuE=";
  };
  hardeningDisable = [
    "pic"
    "format"
  ];
  nativeBuildInputs = kernel.moduleBuildDependencies;

  enableParallelBuilding = true;

  KSRC = "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build";
  INSTALL_MOD_PATH = placeholder "out";

  makeFlags = kernel.commonMakeFlags or kernel.makeFlags;
  preBuild = ''
    makeFlags="$makeFlags -C ${finalAttrs.KSRC} M=$(pwd)"
  '';
  installTargets = [ "modules_install" ];

  passthru.updateScript = unstableGitUpdater {
    url = "https://github.com/strongtz/i915-sriov-dkms";
  };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "DKMS module of Linux i915 driver with SR-IOV support";
    homepage = "https://github.com/strongtz/i915-sriov-dkms";
    license = lib.licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
  };
})
