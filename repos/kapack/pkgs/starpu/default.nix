{ stdenv, fetchFromGitLab, lib, gnumake, gcc, libtool, autoconf, automake, pkg-config, fftw, hwloc, bashInteractive }:

stdenv.mkDerivation rec {
  pname = "starpu";
  version = "1.4.0";
  src = fetchFromGitLab {
    domain = "gitlab.inria.fr";
    owner = pname;
    repo = pname;
    rev = "${pname}-${version}";
    sha256 = "sha256-EwS/BKMdRfn1U/ln1ezbg03zF8XiNMquGBRPe9WAeqw=";
  };
  buildInputs = [
    gnumake
    gcc
    libtool
    autoconf
    automake
    pkg-config
    fftw
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

