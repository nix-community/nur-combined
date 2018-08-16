{ writeText }:

writeText "buildman.conf" ''
    [toolchain]
    root: /

    [toolchain-prefix]
    # Sandbox will link against the system libc, so use the native compiler.
    sandbox:

    # For Bootlin toolchains:
    # Sadly I couldn't get all of U-Boot to build, at least MIPS and sh2 have problems, also RISC-V is missing.
    # aarch64: aarch64-linux-
    # arc: arc-linux-
    # arm: arm-linux-
    # m68k: m68k-linux-
    # microblaze: microblazeel-linux-
    # mips: mips-linux-
    # nios2: nios2-linux-
    # powerpc: powerpc-linux-
    # sh: sh4-linux-
    # xtensa: xtensa-linux-

    # For kernel.org toolchains:
    # All except nds32 builds fine.
    aarch64: aarch64-linux-
    arc: arc-linux-
    arm: arm-linux-gnueabi-
    m68k: m68k-linux-
    microblaze: microblaze-linux-
    mips: mips-linux-
    nios2: nios2-linux-
    powerpc: powerpc-linux-
    riscv: riscv64-linux-
    sh: sh4-linux-
    x86_64: x86_64-linux-
    xtensa: xtensa-linux-

    # Doesn't work for some reason
    # nds32le: nds32le-linux-

    [toolchain-alias]
    blackfin = bfin
    nds32 = nds32le
    openrisc = or1k
    x86 = x86_64
''
