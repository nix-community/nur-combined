{ stdenv
, fetchgit
, autoconf, automake
, curl, gawk, bc, gperf
, libmpc, mpfr, gmp, bison, flex, texinfo, libtool, patchutils, zlib, expat
}:

stdenv.mkDerivation {
  name = "riscv-gnu-toolchain";
  src = fetchgit {
    url = "https://github.com/riscv/riscv-gnu-toolchain";
    rev = "9ef0948c4b3a71088cf4df6be93d8e014ba27731";
    sha256 = "188f2pbdqpvqcjkml4x4kawznnf20z8fhxc1wwda3zf5p5n9xwnf";
    fetchSubmodules = true;
  };

  # It also dumps a 'riscv64-unknown-elf' with a separate bin/lib, so we move
  # that to a separate output
  outputs = [ "out" "elf" ];

  nativeBuildInputs = [ autoconf automake ];
  buildInputs = [
    curl gawk bc gperf
    libmpc mpfr gmp bison flex texinfo libtool patchutils zlib expat
  ];

  NIX_CFLAGS_COMPILE = "-Wno-error=format-security";

  enableParallelBuilding = true;

  postInstall = ''
    mv "$out/riscv64-unknown-elf" "$elf"
  '';

  meta = with stdenv.lib; {
    description = "GNU toolchain for RISC-V, including GCC";
    homepage = "https://github.com/riscv/riscv-gnu-toolchain";
    platforms = platforms.unix;
    license = licenses.gpl2;
  };
}

