{ stdenv, lib, fetchurl, openmpi, automake, gfortran, bc, benchs ? "ep cg mg ft bt sp lu", classes ? "A B C D E F", buildOmp ? true }:

stdenv.mkDerivation rec {
  name = "NPB-${version}";
  version = "3.4.2";

  src = fetchurl {
    url = "https://www.nas.nasa.gov/assets/npb/NPB${version}.tar.gz";
    sha256 = "sha256-+741tZRgainW9v3GQRK8mIvO5lxpvkobAS+E3u1nmuw=";
  };

  nativeBuildInputs = [ openmpi automake gfortran bc ];
  
  #   NPB3.4-OMP #B C D E / is ep cg mg ft bt sp lu
  buildPhase = ''
  mkdir -p $out/bin

  for nbp_dir in NPB3.4-MPI${lib.optionalString buildOmp " NPB3.4-OMP"}
  do
    cd $nbp_dir

    cp config/make.def{.template,}

    sed -i 's/^MPIF77.*/MPIF77 = mpif77/' config/make.def
    sed -i 's/^MPICC.*/MPICC = mpicc/' config/make.def
    sed -i 's/^FFLAGS.*/FFLAGS  = -fallow-argument-mismatch -O -mcmodel=medium/' config/make.def

    # need to build setparams before to use parallel build 
    make -C sys

    for class in ${classes}
    do
      for bench in ${benchs}
      do
        # Not all bench are compiling so skip the errors
        make -j $(nproc) $bench CLASS=$class || echo \
        "Warning: the bench $bench $class is not compiling"
      done
    done
    cd ..
  done
  '';

  installPhase = ''
  for nbp_type in mpi${lib.optionalString buildOmp " omp"}
  do
    cd NPB3.4-''${nbp_type^^}/bin
    for f in *.x
    do
      echo "$f" "$out/''${f%.x}.$nbp_type" 
      cp "$f" "$out/bin/''${f%.x}.$nbp_type" 
    done
    cd ../..
  done
  '';

  enableParallelBuilding = true;

  meta = with lib; {
    description = ''
    The NAS Parallel Benchmarks (NPB) are a small set of programs designed to
    help evaluate the performance of parallel supercomputers. The benchmarks
    are derived from computational fluid dynamics (CFD) applications and
    consist of five kernels and three pseudo-applications in the original
    "pencil-and-paper" specification (NPB 1). The benchmark suite has been
    extended to include new benchmarks for unstructured adaptive mesh,
    parallel I/O, multi-zone applications, and computational grids.  Problem
    sizes in NPB are predefined and indicated as different classes. Reference
    implementations of NPB are available in commonly-used programming models
    like MPI and OpenMP (NPB 2 and NPB 3)
    '';
    homepage    = "https://www.nas.nasa.gov/publications/npb.html";
    platforms   = platforms.unix;
  };
}
