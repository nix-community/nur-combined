# DOES NOT YET WORK!
# N.B. This is a hacky copy-paste with in-place modification from the standard libgcc:
# https://github.com/NixOS/nixpkgs/blob/master/pkgs/development/libraries/gcc/libgcc/default.nix
# Unlike the upstream Nix libgcc package, here we aren't bootstrapping stdenv
# and thus have access to a full featured compiler, so it ought to be simpler.
#
# Instructions for how to build libgccjit normally are here:
# https://gcc.gnu.org/onlinedocs/jit/internals/index.html
{ stdenv
, gcc
, glibc
, gmp
, libelf
, libiberty
, libmpc
, mpfr
}:

stdenv.mkDerivation rec {
  pname = "libgcc";
  inherit (gcc.cc) src version;

  outputs = [ "out" "dev" ];

  nativeBuildInputs = [ libiberty ];
  buildInputs = [ gmp mpfr libmpc libelf gcc ];

  hardeningDisable = [ "format" ];

  configurePhase = ''
    mkdir build && cd build
    mkdir -p gcc/include

    ../configure \
      --disable-fixincludes \
      --disable-intl \
      --disable-libatomic \
      --disable-libbacktrace \
      --disable-libcpp \
      --disable-libgomp \
      --disable-libquadmath \
      --disable-libssp \
      --disable-libvtv \
      --disable-lto \
      --disable-static \
      --disable-multilib \
      --disable-vtable-verify \
      --enable-host-shared \
      --enable-languages=jit \
      --prefix=$out \

  '';

  enableParallelBuilding = false;

  inherit (gcc) meta;
}
