{ stdenv, lib, fetchurl, fasm, pkg-config }:

stdenv.mkDerivation rec {
  pname = "linasm";
  version = "1.13";
  name = "${pname}-${version}";

  src = fetchurl {
    name = "${name}.tar.gz";
    url = "mirror://sourceforge/project/linasm/${pname}-${version}%28stable%29.tar.gz";
    sha256 = "09wa8zyrwh7l49csckgr5vry2b4nkcssnfvzdsfgc9yxzdfl9ali";
  };

  nativeBuildInputs = [ fasm pkg-config ];

  installPhase = ''
    make install prefix=$out
    '';

  postFixup = ''
    mkdir $out/lib/pkgconfig
    echo "prefix=$out
exec_prefix=$out
libdir=$out/lib
includedir=$out/include

Name: LinAsm
Description: SIMD optimized assembly libraries for common and wide used algorithms.
Version: 1.13
Libs: -L$out/lib -llinasm
Cflags: -I$out/include" > $out/lib/pkgconfig/linasm.pc
    '';

  meta = with lib; {
    description = "LinAsm is collection of very fast and SIMD optimized libraries, are written in pure assembly language (FASM) for x86-64 Linux systems.";
    homepage = "https://sourceforge.net/projects/linasm/";
    license = licenses.lgpl3;
    platforms = platforms.unix;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
