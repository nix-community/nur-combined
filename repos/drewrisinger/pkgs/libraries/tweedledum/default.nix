{ stdenv
, fetchFromGitHub
, cmake
, fmt
, nlohmann_json
, pybind11
# , zlib
}:
let
  fmt-header-only = fmt.overrideAttrs(oldAttrs: { cmakeFlags = oldAttrs.cmakeFlags ++ [ "-DFMT_HEADER_ONLY=1" ];});
in
stdenv.mkDerivation rec {
  pname = "tweedledum";
  version = "1.0.0";

  src = fetchFromGitHub{
    owner = "boschmitt";
    repo = "tweedledum";
    rev = "v${version}";
    sha256 = "0bpnz38cya166nxnsqnx9xlzk2svranzss9w01yv471xvk6lkng7";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [
    # fmt-header-only.dev
    nlohmann_json
    pybind11
    # zlib
  ];

  cmakeFlags = [
    "-DTWEEDLEDUM_PYBINDS=OFF"
    "-DTWEEDLEDUM_TESTS=ON"
    "-DTWEEDLEDUM_USE_EXTERNAL_JSON=ON"
    "-DTWEEDLEDUM_USE_EXTERNAL_PYBIND11=ON"
    # "-DTWEEDLEDUM_USE_EXTERNAL_FMT=ON"
    # "-DFMT_HEADER_ONLY=1"
  ];

  doCheck = true;
  doInstallCheck = true;

  checkPhase = ''
    ./test/run_tests
  '';

  meta = with stdenv.lib; {
    description = "Library for writing, manipulating, and optimizing quantum circuits";
    homepage = "https://github.com/boschmitt/tweedledum";
    license = licenses.mit ;
    maintainers = with maintainers; [ drewrisinger ];
    broken = true;  # doesn't install anything, https://github.com/boschmitt/tweedledum/issues/129
  };
}
