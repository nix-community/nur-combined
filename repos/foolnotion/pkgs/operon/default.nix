{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  # build inputs
  aria-csv,
  ceres-solver,
  cxxopts,
  eigen,
  fast_float,
  fmt,
  glog,
  git,
  jemalloc,
  openlibm,
  pkg-config,
  pratt-parser,
  robin-hood-hashing,
  scnlib,
  span-lite,
  taskflow,
  vectorclass,
  vstat,
  xxhash,
  # build options
  useSinglePrecision ? true,
  buildCliPrograms ? true,
  buildSharedLibs ? true,
  useOpenLibm ? true,
  useJemalloc ? false
}:
stdenv.mkDerivation rec {
  pname = "operon";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "heal-research";
    repo = "operon";
    rev = "2c1edf616dc51c8a6eb2ff214bb63d4766b28064";
    sha256 = "sha256-GK7CCQcMHJGDuc1DWi0rg9/+TLfbC46cpd4K0HFLwJ0=";
  };

  nativeBuildInputs = [ cmake git ];

  buildInputs = [
    aria-csv
    ceres-solver
    eigen
    fast_float
    fmt
    git
    glog
    pkg-config
    pratt-parser
    robin-hood-hashing
    scnlib
    span-lite
    taskflow
    vectorclass
    vstat
    xxhash
  ] ++ lib.optionals buildCliPrograms [ cxxopts ]
    ++ lib.optionals useOpenLibm [ openlibm ]
    ++ lib.optionals useJemalloc [ jemalloc ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DUSE_SINGLE_PRECISION=${if useSinglePrecision then "ON" else "OFF"}"
    "-DBUILD_CLI_PROGRAMS=${if buildCliPrograms then "ON" else "OFF"}"
    "-DBUILD_SHARED_LIBS=${if buildSharedLibs then "ON" else "OFF"}"
    "-DUSE_JEMALLOC=${if useJemalloc then "ON" else "OFF"}"
    "-DUSE_OPENLIBM=${if useOpenLibm then "ON" else "OFF"}"
  ];

  meta = with lib; {
    description = "Modern, fast, scalable C++ framework for symbolic regression.";
    homepage = "https://github.com/heal-research/operon";
    license = licenses.mit;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
