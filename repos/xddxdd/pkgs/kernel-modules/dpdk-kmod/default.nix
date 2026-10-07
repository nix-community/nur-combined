{
  fetchgit,
  unstableGitUpdater,
  stdenv,
  lib,
  kernel,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "dpdk-kmod";
  version = "0-unstable-2024-11-20";
  src = fetchgit {
    url = "git://dpdk.org/dpdk-kmods";
    rev = "9b182be2ee4bf003c892e1312440e1e5d93eff2c";
    fetchSubmodules = false;
    hash = "sha256-8XXLJT18ivnTJcHaCefRpbsuG9K/yERaHbNMHH4l62A=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  preConfigure = ''
    cd linux/igb_uio
  '';

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

  passthru.updateScript = unstableGitUpdater {
    url = "git://dpdk.org/dpdk-kmods";
    hardcodeZeroVersion = true;
  };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "DPDK kernel modules or add-ons";
    homepage = "https://git.dpdk.org/dpdk-kmods/";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.linux;
  };
})
