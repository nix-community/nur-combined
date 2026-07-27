{
  stdenv, fetchgit,
  autoconf, automake, pkg-config, curl, python312, python312Packages, libmpc, gmp, cmake, git, glib, ninja, bc, bison, flex, texinfo, flock, which, gettext, mpfr, isl
}:
let
  pname = "riscv-gnu-toolchain";
  version = "2025.05.10";
  src = fetchgit {
    url = "https://github.com/riscv-collab/riscv-gnu-toolchain.git";
    rev = "refs/tags/${version}";
    hash = "sha256-aCCjuQreHThX9UwaObvx8HS60TOxf8codqJRJhThxe8=";
    fetchSubmodules = true;
    leaveDotGit = true;
  };

in
stdenv.mkDerivation {
  inherit pname version src;
  # https://github.com/risc0/toolchain/blob/main/build.sh
  configureFlags = [
    "--with-cmodel=medany"
    "--disable-gdb"
    "--with-arch=rv32im"
    "--with-abi=ilp32"
    # https://github.com/NixOS/nixpkgs/blob/master/pkgs/development/compilers/gcc/common/configure-flags.nix#L139
    # "--with-gmp-include=${gmp.dev}/include"
    # "--with-gmp-lib=${gmp.out}/lib"
    # "--with-mpfr-include=${mpfr.dev}/include"
    # "--with-mpfr-lib=${mpfr.out}/lib"
    # "--with-mpc=${libmpc}"
  ];
  postUnpack = ''
  rm ${pname}/gcc/contrib/download_prerequisites

  ls -lah
  tar xjf ${gmp.src}
  mv gmp-${gmp.version} ${pname}/gcc/gmp

  tar xzf ${gettext.src}
  mv gettext-${gettext.version} ${pname}/gcc/gettext

  tar xzf ${libmpc.src}
  mv mpc-${libmpc.version} ${pname}/gcc/mpc

  tar xJf ${mpfr.src}
  mv mpfr-${mpfr.version} ${pname}/gcc/mpfr

  tar xJf ${isl.src}
  mv isl-${isl.version} ${pname}/gcc/isl
  '';

  dontUseCmakeConfigure = true;
  dontUseNinjaBuild = true;
  dontUseNinjaInstall = true;
  dontUseNinjaCheck = true;
  hardeningDisable = [ "all" ]; # Disable all hardening flags

  # $ sudo apt-get install autoconf automake autotools-dev curl
  # python3 python3-pip libmpc-dev libmpfr-dev libgmp-dev gawk
  # build-essential bison flex texinfo gperf libtool patchutils bc
  # zlib1g-dev libexpat-dev ninja-build git cmake libglib2.0-dev
  nativeBuildInputs = [
    pkg-config
    autoconf
    automake
    which

    curl
    python312
    python312Packages.pip
    libmpc
    cmake
    git
    glib
    ninja
    bc
    bison
    texinfo
    flex
    flock
    gettext
  ];

}
