{ lib
, stdenv
, fetchFromGitHub
, cmake
, conan
, eigen
, ninja
, boost
, fmt
, spdlog
, symengine
, nlohmann_json
}:

stdenv.mkDerivation rec {
  pname = "tket";
  version = "0.19.2";

  # src = fetchFromGitHub {
  #   owner = "cqcl";
  #   repo = pname;
  #   rev = "v${version}";
  #   sha256 = "sha256-V8w1qTR/pZY/P7T8WH4rTpP6LkFfMszmpkwioa5MnIg=";
  # };
  src = lib.cleanSource /home/drewrisinger/github/tket;

  cmakeFlags = [
    # "--trace-expand"
    # "-DSPDLOG_FMT_EXTERNAL=ON"
  ];

  sourceRoot = "source/tket/src";

  nativeBuildInputs = [ cmake ninja ];

  buildInputs = [
    eigen
    symengine
    boost
    spdlog
    nlohmann_json
  ];

  meta = with lib; {
    description = "TKET quantum compiler, Python bindings and utilities";
    homepage = "https://github.com/CQCL/tket/";
    license = licenses.asl20;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
