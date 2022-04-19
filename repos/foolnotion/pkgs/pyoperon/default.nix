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
    rev = "20127de3d5afe480762b56bc2d09298ffaaa4150";
    sha256 = "sha256-tunhlBJPFKdqvAUD0S2TpsTJNcrvRcfUzTGW1MoTtvc=";
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
