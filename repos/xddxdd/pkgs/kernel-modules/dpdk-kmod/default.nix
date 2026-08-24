{
  fetchgit,
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
  preConfigure = ''
    cd linux/igb_uio
  '';

  hardeningDisable = [
    "pic"
    "format"
  ];
  nativeBuildInputs = kernel.moduleBuildDependencies;

  KSRC = "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build";
  INSTALL_MOD_PATH = placeholder "out";

  makeFlags = kernel.commonMakeFlags or kernel.makeFlags;
  preBuild = ''
    makeFlags="$makeFlags -C ${finalAttrs.KSRC} M=$(pwd)"
  '';
  installTargets = [ "modules_install" ];

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "DPDK kernel modules or add-ons";
    homepage = "https://git.dpdk.org/dpdk-kmods/";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.linux;
  };
})
