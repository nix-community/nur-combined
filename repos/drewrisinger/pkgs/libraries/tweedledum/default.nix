{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, cmake
, ninja
, fmt
, nlohmann_json
, python3
}:
stdenv.mkDerivation rec {
  pname = "tweedledum";
  version = "1.1.1";

  src = fetchFromGitHub{
    owner = "boschmitt";
    repo = "tweedledum";
    rev = "v${version}";
    sha256 = "sha256-wgrY5ajaMYxznyNvlD0ul1PFr3W8oV9I/OVsStlZEBM=";
  };

  patches = [
    (fetchpatch {
      name = "pr-173-update-catch2.patch";
      url = "https://github.com/boschmitt/tweedledum/commit/2791ff2588c149ad10196b3989c8faa0e1237c32.patch";
      sha256 = "sha256-ZRKrtr+xNKCPFC8Vzbql/0pENLytu8kuL7yLycr9CO8=";
    })
  ];

  nativeBuildInputs = [ cmake ninja ];
  buildInputs = [
    nlohmann_json
    (python3.withPackages(ps: [ ps.pybind11 ]))
  ];

  cmakeFlags = [
    "-DTWEEDLEDUM_PYBINDS=OFF"
    "-DTWEEDLEDUM_TESTS=ON"
    "-DTWEEDLEDUM_USE_EXTERNAL_PYBIND11=ON"
  ];

  doCheck = true;
  doInstallCheck = true;

  checkPhase = ''
    ./tests/run_tests
  '';

  meta = with lib; {
    description = "Library for writing, manipulating, and optimizing quantum circuits";
    homepage = "https://github.com/boschmitt/tweedledum";
    license = licenses.mit ;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
