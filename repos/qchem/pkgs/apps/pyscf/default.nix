{ buildPythonPackage, lib, fetchFromGitHub, libcint, libxc, xcfun, blas,
  numpy, scipy, h5py, python3
} :

buildPythonPackage rec {
  pname = "pyscf";
  version = "1.7.6";

  src = fetchFromGitHub {
    owner = "pyscf";
    repo = pname;
    rev = "v${version}";
    sha256  = "1plicf3df732mcwzsinfbmlzwwi40sh2cxy621v7fny2hphh14dl";
  };

  buildInputs = [
    libcint
    libxc
    xcfun
    blas
  ];

  propagatedBuildInputs = [
    numpy
    scipy
    h5py
    python3
  ];

  PYSCF_INC_DIR="${libcint}:${libxc}";

  doCheck = false;

  meta = with lib; {
    description = "Python-based simulations of chemistry framework";
    homepage = https://pyscf.github.io/;
    license = licenses.asl20;
    platforms = platforms.linux;
  };
}
