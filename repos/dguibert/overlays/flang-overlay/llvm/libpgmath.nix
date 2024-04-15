{
  stdenv,
  version,
  flang_src,
  cmake,
  llvm,
  python,
}:
stdenv.mkDerivation {
  name = "libpgmath-${version}";
  src = flang_src;

  buildInputs = [cmake llvm python];

  preConfigure = ''
    # build libpgmath
    cd runtime/libpgmath
    sed -i -e 's@int fprintf(FILE \*, const char \*, ...);@@' lib/common/pgstdinit.h
    sed -i -e 's@int printf(const char \*, ...);@@' lib/common/pgstdinit.h
  '';
}
