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
  buildSharedLibs ? true
}:
stdenv.mkDerivation rec {
  pname = "operon";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "heal-research";
    repo = "operon";
    rev = "7a6eee8b4c94ac056b66eec27831bc0a8c5ecd1d";
    sha256 = "sha256-gswTWOuswlJmb1J41zFT/TM0zKhsMwY4KVY+lG8D3rg=";
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
    pratt-parser
    robin-hood-hashing
    scnlib
    span-lite
    taskflow
    vectorclass
    vstat
    xxhash
  ] ++ lib.optionals buildCliPrograms [ cxxopts ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DUSE_SINGLE_PRECISION=${if useSinglePrecision then "ON" else "OFF"}"
    "-DBUILD_CLI_PROGRAMS=${if buildCliPrograms then "ON" else "OFF"}"
    "-DBUILD_SHARED_LIBS=${if buildSharedLibs then "ON" else "OFF"}"
  ];

  meta = with lib; {
    description = "Modern, fast, scalable C++ framework for symbolic regression ";
    homepage = "https://github.com/heal-research/operon";
    license = licenses.mit;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
