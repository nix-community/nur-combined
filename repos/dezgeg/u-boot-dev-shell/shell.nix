{ stdenv, kernelOrgToolchains, bootlinToolchains, flex, bison, swig, python2, openssl, lzop, dtc, iasl }:

stdenv.mkDerivation {
  name = "u-boot-dev-shell";

  nativeBuildInputs = [ flex bison swig python2 openssl lzop dtc iasl ] ++ (with kernelOrgToolchains; [
      aarch64
      arc
      arm
      m68k
      microblaze
      mips
      mips64
      nds32le
      nios2
      powerpc
      powerpc64
      riscv64
      sh2
      sh4
      sparc
      x86_64
      xtensa
    ]);

    # Bootlin toolchains have too many failures on e.g. MIPS and sh2
    # with bootlinToolchains; [
    #  aarch64.glibc.bleeding-edge
    #  arcle-hs38.glibc.bleeding-edge
    #  armv7-eabihf.glibc.bleeding-edge
    #  m68k-68xxx.uclibc.bleeding-edge
    #  microblazeel.glibc.bleeding-edge
    #  mips64el-n32.glibc.bleeding-edge
    #  nios2.glibc.bleeding-edge
    #  powerpc-e500mc.glibc.bleeding-edge
    #  sh-sh4.glibc.bleeding-edge
    #  x86-64-core-i7.glibc.bleeding-edge
    #  xtensa-lx60.uclibc.bleeding-edge
    # ];

  hardeningDisable = [ "all" ];

  NO_SDL = 1;
}
