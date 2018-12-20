{ stdenv
, gfortran ? null
}:

stdenv.mkDerivation {
  name = "stream";

  buildInputs = [ gfortran ];
  phases = [ "buildPhase" ];
  buildPhase = ''
    set -x
    mkdir -p $out/bin
    ''${CC:-gcc} $CFLAGS ${./stream.c} -o $out/bin/stream_c
  '' + stdenv.lib.optionalString (gfortran != null) ''
    ''${CC:-gcc} $CFLAGS -c ${./mysecond.c} -o mysecond.o
    ''${FC:-gfortran} $FFLAGS -c ${./stream.f} -o stream.o
    ''${FC:-gfortran} $FFLAGS stream.o mysecond.o -o $out/bin/stream_f
  '' + ''
    set +x
  '';
}
