{
  stdenv,
  fetchFromGitLab,
  lib,
  gnumake,
  gcc,
  libtool,
  autoconf,
  automake,
  pkg-config,
  hwloc,
  bashInteractive,
  cudaPackages,
  maxCPUs ? 64,
  maxNUMANodes ? 16,
  maxCUDADev ? 8,
  useCUDA ? false,
  useMPI ? false,
  openmpi,
  useFFT ? false,
  fftw,
}:

stdenv.mkDerivation rec {
  pname = "starpu";
  version = "1.4.12";
  src = fetchFromGitLab {
    domain = "gitlab.inria.fr";
    owner = pname;
    repo = pname;
    rev = "${pname}-${version}";
    sha256 = "sha256-GJ8SFW62nNj/MMKt5ewYL7PugpB2lRxZYdjJf4/mUME=";
  };
  buildInputs = [
    gnumake
    gcc
    libtool
    autoconf
    automake
    pkg-config
  ]
  ++ lib.optional useFFT [
    fftw
  ]
  ++ lib.optional useMPI [
    openmpi
  ]
  ++ lib.optional useCUDA [
    cudaPackages.cudatoolkit
  ];
  propagatedBuildInputs = [
    hwloc
  ];
  enableParallelBuilding = true;
  patchPhase = ''
    substituteInPlace doc/extractHeadline.sh --replace "/bin/bash" "${bashInteractive}/bin/bash"
    substituteInPlace doc/fixLinks.sh --replace "/bin/bash" "${bashInteractive}/bin/bash"
    sh autogen.sh
  '';
  configureFlags = [
    "--enable-fast"
    "--enable-maxcpus=${builtins.toString maxCPUs}"
    "--disable-build-doc"
    "--with-hwloc=${hwloc.dev}"
  ]
  ++ lib.optional (!useFFT) [
    "--disable-starpufft"
  ]
  ++ lib.optional (!useMPI) [
    "--disable-mpi"
  ]
  ++ lib.optional useCUDA [
    "--enable-maxnumanodes=${builtins.toString maxNUMANodes}"
    "--enable-maxcudadev=${builtins.toString maxCUDADev}"
    "--with-cuda-dir=${cudaPackages.cudatoolkit}"
  ];
  meta = with lib; {
    homepage = "https://gitlab.inria.fr/starpu/starpu";
    description = "Run-time system for heterogeneous computing";
    license = licenses.lgpl21Plus;
    longDescription = ''
      StarPU is a run-time system that offers support for heterogeneous
      multicore machines.  While many efforts are devoted to design efficient
      computation kernels for those architectures (e.g. to implement BLAS kernels
      on GPUs), StarPU not only takes care of offloading such kernels (and
      implementing data coherency across the machine), but it also makes sure the
      kernels are executed as efficiently as possible.
    '';
  };
}
