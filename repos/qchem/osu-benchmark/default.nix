{ lib, stdenv, fetchurl, mpi } :
let
  version = "5.6.3";

in stdenv.mkDerivation {
  name = "osu-benchmark-${version}";

  src = fetchurl {
    url = "http://mvapich.cse.ohio-state.edu/download/mvapich/osu-micro-benchmarks-${version}.tar.gz";
    sha256 = "1f5fc252c0k4rd26xh1v5017wfbbsr2w7jm49x8yigc6n32sisn5";
  };

  buildInputs = [ mpi ];

  preConfigure = ''
    export CXX="${mpi}/bin/mpicc"
    export CC="${mpi}/bin/mpicxx"
  '';

  postInstall = ''
    mkdir $out/bin

    cat > $out/bin/osu_run_all << EOF
    #!${stdenv.shell}
    for i in `find $out/libexec -type f | tr '\n' ' '`; do
      ${mpi}/bin/mpirun -np 2 \$i
    done
    EOF
  '';

  meta = with lib; {
    description = "MPI micro benchmark suite";
    homepage = "http://mvapich.cse.ohio-state.edu/benchmarks";
    maintainers = [ maintainers.markuskowa ];
    license = licenses.bsd3;
    platforms = platforms.linux;
  };
}

