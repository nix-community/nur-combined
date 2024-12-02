# C code is taken from megi's kernel tree.
# this is a patched version of mainline driver.
# notably, it resolves some errors like "rt5640 1-001c: ASoC: error at snd_soc_dai_set_sysclk on rt5640-aif1: -22".
#
# the driver source lives at sound/soc/codecs/rt5640.c; it's renamed to sound-soc-rt5640 during build
{
  buildPackages,
  kernel,
  lib,
  stdenv,
}:

stdenv.mkDerivation {
  pname = "rt5640";
  version = "0-unstable-2024-02-21";

  src = ./.;

  hardeningDisable = [ "pic" ];
  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = [
    # "KERNELRELEASE=${kernel.modDirVersion}"
    "KERNEL_DIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
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

  # the modules shipped in-tree are .xz, so if i want to replace those i need to also xz this module:
  postInstall = ''
    find $out -name '*.ko' -exec xz {} \;
  '';

  passthru.moduleNames = [
    "sound-soc-rt5640"    #< mainline, patched module
  ];
}

