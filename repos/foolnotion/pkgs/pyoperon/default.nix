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
    rev = "264e111264d3986e389103d33f98a793aa837e3d";
    sha256 = "sha256-8fpOpN1MabB88BX8gvtIIvQHbIb0u5u3sieU0bLTDu0=";
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
