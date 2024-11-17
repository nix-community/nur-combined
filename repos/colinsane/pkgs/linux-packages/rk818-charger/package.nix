# C code is taken from megi's kernel tree,
# which he appears to have taken from the Rockchip BSP
#   i.e. https://github.com/rockchip-linux/kernel
# Rockchip rk818 seems to have seen no development after 2021-06-09 (as of 2024-10-01)
#
# mainline linux contains `drivers/mfd/rk8xx-core.c` and `Documentation/devicetree/bindings/mfd/rockchip,rk818.yaml`
# the former includes "rk817-charger", but nothing for the rk818.
# the latter includes the PMIC, without mention of any battery/charger.
# hmm...
#
# this package is part of the `linuxKernel.packagesFor ...` scope(s).
# build it e.g.:
# - `nix-build -A linuxPackages_6_11.rk818-charger`
# - `nix-build -A hosts.moby.config.boot.kernelPackages.rk818-charger`
{
  buildPackages,
  kernel,
  lib,
  stdenv,
}:

stdenv.mkDerivation {
  pname = "rk818-charger";
  version = "0-unstable-2024-10-01";

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

  # AFAICT the module names are really just the .o files.
  # i guess if you wanted a module with more than one file,
  # you would compile all their .c sources into one .o and add just that to `obj-m`?
  #
  # patched *and* unpatched modules are provided here, because the kernel config is such that
  # certain mainline drivers (rk8xx-i2c) can't be compiled as module without also compiling
  # their runtime dependencies (rk8xx-core), so i end up disabling the whole tree in Kconfig.
  passthru.moduleNames = [
    "rk818_battery"    #< new module
    "rk818_charger"    #< new module
    "rk8xx-core"       #< mainline, patched
    "rk8xx-i2c"        #< mainline, patched
  ];
}
