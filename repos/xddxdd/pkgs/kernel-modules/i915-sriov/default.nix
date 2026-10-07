{
  fetchFromGitHub,
  unstableGitUpdater,
  stdenv,
  lib,
  kernel,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "i915-sriov";
  version = "2026.09.16-unstable-2026-10-02";
  src = fetchFromGitHub {
    owner = "strongtz";
    repo = "i915-sriov-dkms";
    rev = "f4cb98f4c28e1f3ac78ca88501a87c86d0c21a88";
    hash = "sha256-YOsXy/B0/f0rdFV+xJwu64//Er0/v3ELEHov9TN1kUQ=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  hardeningDisable = [
    "pic"
    "format"
  ];
  patches = [ ./kernel-6.18.55-drm-client.patch ];
  nativeBuildInputs = kernel.moduleBuildDependencies;

  enableParallelBuilding = true;

  env.KSRC = "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build";
  env.INSTALL_MOD_PATH = placeholder "out";

  makeFlags = kernel.commonMakeFlags or kernel.makeFlags;
  preBuild = ''
    makeFlagsArray+=("-C" "${finalAttrs.env.KSRC}" "M=$(pwd)")
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
