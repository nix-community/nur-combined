{ stdenv, lib, buildPythonPackage, fetchFromGitHub, autoreconfHook, pkg-config
, gfortran, mpi, blas, lapack, fftw, hdf5-mpi, swig, gsl, harminv, libctl
, libGDSII, openssh, guile
# Python
, python, numpy, scipy, matplotlib, h5py-mpi, cython, autograd, mpi4py
} :

buildPythonPackage rec {
  pname = "meep";
  version = "1.18.0";

  src = fetchFromGitHub {
    owner = "NanoComp";
    repo = pname;
    rev = "v${version}";
    sha256= "08l4mczkh08dp90c4dlnyx6lsg093li0xqnnbh7q8k363cr8lx81";
  };

  nativeBuildInputs = [
    autoreconfHook
    gfortran
    pkg-config
    swig
    mpi
  ];

  buildInputs = [
    gsl
    blas
    lapack
    fftw
    hdf5-mpi
    harminv
    libctl
    libGDSII
    guile
    gsl
  ];

  propagatedBuildInputs = [
    mpi
    numpy
    scipy
    matplotlib
    h5py-mpi
    cython
    autograd
    mpi4py
  ];

  propagatedUserEnvPkgs = [ mpi ];

  dontUseSetuptoolsBuild = true;
  dontUsePipInstall = true;
  dontUseSetuptoolsCheck = true;

  HDF5_MPI = "ON";
  PYTHON = "${python}/bin/${python.executable}";

  enableParallelBuilding = true;

  configureFlags = [
    "--without-libctl"
    "--enable-shared"
    "--with-mpi"
    "--with-openmp"
    "--enable-maintainer-mode"
  ];

  passthru = { inherit mpi; };

  checkInputs = [ openssh ];
  doCheck = true;
  checkPhase = ''
    export PYTHONPATH="$out/lib/${python.libPrefix}/site-packages:$PYTHONPATH"

    export OMP_NUM_THREADS=1

    # Fix to make mpich run in a sandbox
    export HYDRA_IFACE=lo
    export OMPI_MCA_rmaps_base_oversubscribe=1

    # Generate a python test script
    cat > test.py << EOF
    import meep as mp
    cell = mp.Vector3(16,8,0)
    geometry = [mp.Block(mp.Vector3(mp.inf,1,mp.inf),
                     center=mp.Vector3(),
                     material=mp.Medium(epsilon=12))]
    sources = [mp.Source(mp.ContinuousSource(frequency=0.15),
                     component=mp.Ez,
                     center=mp.Vector3(-7,0))]
    pml_layers = [mp.PML(1.0)]
    resolution = 10
    sim = mp.Simulation(cell_size=cell,
                    boundary_layers=pml_layers,
                    geometry=geometry,
                    sources=sources,
                    resolution=resolution)
    sim.run(until=200)
    EOF

    ${mpi}/bin/mpiexec -np 2 python3 test.py
  '';

  meta = with lib; {
    description = "Free finite-difference time-domain (FDTD) software for electromagnetic simulations";
    homepage = "https://meep.readthedocs.io/en/latest/";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
    maintainers = [ maintainers.sheepforce ];
  };
}
