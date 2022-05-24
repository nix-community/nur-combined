{ lib, stdenv, fetchFromGitHub, cmake, mpi, hdf5, python3, python3Packages, swig, which }:

stdenv.mkDerivation rec {
  pname = "hpdbscan";
  version = "1.1";

  src = fetchFromGitHub {
    owner = "Markus-Goetz";
    repo = "hpdbscan";
    sha256 = "01f8z2adiyxl4rwlis22f75c718b88fx3flg0aqlrlsmrly14ggx";
    rev = "ae0c74c";
  };

  patches = [ ./numpy.patch ];

  cmakeFlags = [
    "-DNUMPY_INCLUDE_DIR=${python3Packages.numpy}/${python3.sitePackages}/numpy/core/include"
    "-DNUMPY_INCLUDE_DIRS=${python3Packages.numpy}/${python3.sitePackages}/numpy/core/include"
  ];

  preConfigure = ''
    mv cmake/FindNumPy.cmake cmake/FindNUMPY.cmake
  '';

  buildInputs = [
    mpi
    hdf5
    swig
  ];

  nativeBuildInputs = [ cmake which ];

  propagatedBuildInputs = [
    (python3.withPackages (ps: with ps; [ numpy mpi4py ]))
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp hpdbscan $out/bin
    cp _hpdbscan.so $out/bin
    cp libhpdbscan.so $out/bin
    cp hpdbscan.py $out/bin
    ln -s $(which python) $out/bin/python
  '';

  meta = with lib; {
    homepage = "https://github.com/Markus-Goetz/hpdbscan";
    description = "Shared- and distributed-memory parallel implementation of the Density-Based Spatial Clustering for Applications with Noise (DBSCAN) algorithm";
    license = licenses.mit;
    maintainers = with maintainers; [ bzizou ];
  };
}
