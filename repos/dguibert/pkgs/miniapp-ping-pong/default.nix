{ stdenv
, openmpi
, mpi ? openmpi
, caliper
}:

stdenv.mkDerivation {
  name = "miniapp-ping-pong-v0";
  src = ./mpi-ping-pong.c;

  nativeBuildInputs = [ mpi caliper ];

  dontPatchELF = true;
  dontStrip = true;

  phases = [ "buildPhase" ];
  buildPhase = ''
  set -x
    mkdir -p $out/bin
    mpicc -o $out/bin/mpiniapp-ping-pong $src -lcaliper-mpi -lcaliper -lcaliper-reader -lcaliper-common
  set +x
  '';
}
