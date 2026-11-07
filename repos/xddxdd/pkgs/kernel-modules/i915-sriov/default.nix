{
  fetchFromGitHub,
  unstableGitUpdater,
  stdenv,
  lib,
  kernel,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "i915-sriov";
  version = "2026.11.05-unstable-2026-11-05";
  src = fetchFromGitHub {
    owner = "strongtz";
    repo = "i915-sriov-dkms";
    rev = "3fea06d13befa78e876048fa2da481d07e1f60c9";
    hash = "sha256-WFflka8QnGOQ5ZgaiUKd6uNVI5LQ5rB6AFeZb3Yp/is=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  hardeningDisable = [
    "pic"
    "format"
  ];
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
