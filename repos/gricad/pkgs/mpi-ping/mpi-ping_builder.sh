export PATH="$coreutils/bin:$gcc/bin:$openmpi/bin"
mkdir -p $out/bin
mpicc -o $out/bin/mpi-ping $src
