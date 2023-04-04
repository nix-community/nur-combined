{nvsrcs, stdenv}:
stdenv.mkDerivation {
  name = "cakeml";
  patches = [./fix_fd.patch];
  inherit (nvsrcs.cakeml) version src;
  installPhase = ''
mkdir -p $out/{bin,share}
cp Makefile cake basis_ffi.c $out/share
ln -s $out/share/cake $out/bin
'';
}
