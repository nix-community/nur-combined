{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  # build inputs
  aria-csv,
  ceres-solver,
  eigen,
  fast_float,
  fmt,
  glog,
  operon,
  openlibm,
  pkg-config,
  pratt-parser,
  pybind11,
  robin-hood-hashing,
  span-lite,
  taskflow,
  vectorclass,
  vstat,
  xxhash,
}:
stdenv.mkDerivation rec {
  pname = "pyoperon";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "heal-research";
    repo = "pyoperon";
    rev = "cc01114920edd42aabd901688ef77c037bced81e";
    sha256 = "sha256-2NC/qOYRDqcmS0+YzYIJxNS1t5iJtI6TyKKi7q7O3XU=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    aria-csv
    ceres-solver
    eigen
    fast_float
    fmt
    glog
    openlibm
    operon
    pkg-config
    pratt-parser
    pybind11
    robin-hood-hashing
    span-lite
    taskflow
    vectorclass
    vstat
    xxhash
  ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DCMAKE_CXX_FLAGS=${if stdenv.targetPlatform.isx86_64 then "-march=haswell" else ""}"
  ];

  meta = with lib; {
    description = "Scikit-learn module and python bindings and for the Operon library";
    homepage = "https://github.com/heal-research/pyoperon";
    license = licenses.mit;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
