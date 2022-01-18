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
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "heal-research";
    repo = "pyoperon";
    rev = "ecd1307d5bf34b2e05909b8aff210ea73ac2e150";
    sha256 = "sha256-cE5q6yUo1OfKAYPVHXzN8Cq2/tHolTe0mEu29GI4U1s=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    aria-csv
    ceres-solver
    eigen
    fast_float
    fmt
    glog
    operon
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
  ];

  meta = with lib; {
    description = "Scikit-learn module and python bindings and for the Operon library";
    homepage = "https://github.com/heal-research/pyoperon";
    license = licenses.mit;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
