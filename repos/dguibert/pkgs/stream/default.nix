{ stdenv
, gfortran ? null
, flags ? "-DSTREAM_ARRAY_SIZE=80000000 -DNTIMES=200"
}:

stdenv.mkDerivation {
  name = "stream";

  buildInputs = [ gfortran ];
  phases = [ "buildPhase" ];
  buildPhase = ''
    set -x
    mkdir -p $out/bin
    ''${CC:-gcc} $CFLAGS ${flags} ${./stream.c} -o $out/bin/stream_c
  '' + stdenv.lib.optionalString (gfortran != null) ''
    ''${CC:-gcc} $CFLAGS ${flags} -c ${./mysecond.c} -o mysecond.o
    ''${FC:-gfortran} $FFLAGS ${flags} -c ${./stream.f} -o stream.o
    ''${FC:-gfortran} $FFLAGS ${flags} stream.o mysecond.o -o $out/bin/stream_f
  '' + ''
    set +x
  '';
}
