# C code is taken from megi's kernel tree.
# this is a patched version of mainline driver.
# actually, mainline has diverged, so we lose some improvements at the benefit of others.
# notably, megi fixed some purported power-on bugs.
# the critical part of megi's patch appears to be changing the clock rate from 1272mbps -> 1224mbps.
# "Pinephone Pro can't do 1272 mbps. This is just a hack to make the new upstream driver work quickly with the phone."
{
  buildPackages,
  kernel,
  lib,
  stdenv,
}:

stdenv.mkDerivation {
  pname = "megi-imx258";
  version = "0-unstable-2024-09-15";

  src = ./.;

  hardeningDisable = [ "pic" ];
  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = [
    # "KERNELRELEASE=${kernel.modDirVersion}"
    # "KERNEL_DIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "KERNEL_DIR=$(buildRoot)"
    "INSTALL_MOD_PATH=$(out)/lib/modules/${kernel.modDirVersion}/kernel"
    # from <repo:nixos/nixpkgs:pkgs/os-specific/linux/kernel/manual-config.nix>
    "O=$(buildRoot)"
    "CC=${stdenv.cc}/bin/${stdenv.cc.targetPrefix}cc"
    "HOSTCC=${buildPackages.stdenv.cc}/bin/${buildPackages.stdenv.cc.targetPrefix}cc"
    "HOSTLD=${buildPackages.stdenv.cc.bintools}/bin/${buildPackages.stdenv.cc.targetPrefix}ld"
    "ARCH=${stdenv.hostPlatform.linuxArch}"
  ] ++ lib.optionals (stdenv.hostPlatform != stdenv.buildPlatform) [
    "CROSS_COMPILE=${stdenv.cc.targetPrefix}"
  ];

  preConfigure = ''
    # starting with linux 6.13.0 it wants to write to `KERNEL_DIR`, so we copy that here to make it writable
    cp -R ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build .
    export buildRoot=$(pwd)/build
  '';

  # the modules shipped in-tree are .xz, so if i want to replace those i need to also xz this module:
  postInstall = ''
    find $out -name '*.ko' -exec xz {} \;
  '';

  passthru.moduleNames = [
    "imx258"    #< mainline, patched module
  ];
}

