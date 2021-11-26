{ pkgs, lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "riscv64-linux-gnu-toolchain";
  version = "31-10-2021";

  src = fetchFromGitHub {
    owner = "riscv-collab";
    repo = "riscv-gnu-toolchain";
    rev = "b39e36160aa0649ba0dfb9aa314d375900d610fb";
    sha256 = "9ksOz+sutD9x7U9JrnMNObAG6TV2HPxf4kqXVAxPF2M=";
    fetchSubmodules = true;
  };

  buildInputs = [
    pkgs.git
    pkgs.flock
    pkgs.curlFull
    pkgs.pythonFull
    pkgs.libmpc
    pkgs.mpfr
    pkgs.gmp
    pkgs.gawk
    pkgs.bison
    pkgs.flex
    pkgs.texinfo
    pkgs.patchutils
    pkgs.zlib
    pkgs.expat
  ];

  configurePhase = ''
    mkdir -p $out
    ./configure --prefix=$out
  '';
  installPhase = ''
    make linux
  '';

  meta = with lib; {
    description = "GNU toolchain for RISC-V, including GCC.";
    homepage = "https://github.com/riscv-collab/riscv-gnu-toolchain";
    license = with licenses; [ gpl2Only ];
    platforms = platforms.linux;
    maintainers = with maintainers; [ uniquepointer ];
    broken = true;
  };
}
