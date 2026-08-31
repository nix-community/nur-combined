# Out-of-tree build of the in-tree WCD934x codec driver, to allow Pocophone-specific fixes.
{
  buildPackages,
  kernel,
  lib,
  stdenv,
}:

stdenv.mkDerivation {
  pname = "pocophone-wcd934x";
  version = "${kernel.version}";

  inherit (kernel) src;

  patches = [
    ./add-stereo-headphone-volume-control.patch
  ];

  postPatch = ''
    cd sound/soc/codecs
    cp ${./Makefile} ./Makefile
  '';

  hardeningDisable = [ "pic" ];
  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = [
    "KERNEL_DIR=$(buildRoot)"
    "INSTALL_MOD_PATH=$(out)/lib/modules/${kernel.modDirVersion}/kernel"
    "O=$(buildRoot)"
    "CC=${stdenv.cc}/bin/${stdenv.cc.targetPrefix}cc"
    "HOSTCC=${buildPackages.stdenv.cc}/bin/${buildPackages.stdenv.cc.targetPrefix}cc"
    "HOSTLD=${buildPackages.stdenv.cc.bintools}/bin/${buildPackages.stdenv.cc.targetPrefix}ld"
    "ARCH=${stdenv.hostPlatform.linuxArch}"
  ] ++ lib.optionals (stdenv.hostPlatform != stdenv.buildPlatform) [
    "CROSS_COMPILE=${stdenv.cc.targetPrefix}"
  ];

  preConfigure = ''
    cp -R ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build .
    export buildRoot=$(pwd)/build
  '';

  postInstall = ''
    find $out -name '*.ko' -exec xz {} \;
  '';

  passthru.moduleNames = [
    "snd-soc-wcd934x"
  ];

  meta = {
    description = "WCD934X codec used by Xiaomi Pocophone with quality-of-life patches";
  };
}
