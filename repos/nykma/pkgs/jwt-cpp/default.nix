{
  lib, fetchgit, stdenv,
  openssl,
  cmake, gtest, nlohmann_json,
  ...
}:
let
  version = "0.7.0";
  src = fetchgit {
    rev = "v${version}";
    url = "https://github.com/Thalhammer/jwt-cpp.git";
    hash = "sha256-aHEPFkXtKDe1CaoTgzMG2DkksFsZnAbE0w81V9TAans=";
  };
  buildInputs = [ openssl ];
  nativeBuildInputs = [ cmake gtest nlohmann_json ];
in
stdenv.mkDerivation {
  inherit version buildInputs nativeBuildInputs;

  pname = "jwt-cpp";
  srcs = [ src ];
  doCheck = true;
  checkPhase = ''
  ./tests/jwt-cpp-test
  '';

  cmakeFlags = [
    # Configure CMake to build examples (or not)
    "-DJWT_BUILD_EXAMPLES=OFF"
    # Configure CMake to build tests (or not)
    "-DJWT_BUILD_TESTS=ON"
    # Adds a target for building the doxygen documentation
    "-DJWT_BUILD_DOCS=OFF"
    # Enable code coverage testing
    "-DJWT_ENABLE_COVERAGE=OFF"
    # Enable fuzz testing
    "-DJWT_ENABLE_FUZZING=OFF"
  ];

  meta = {
    homepage = "https://github.com/Thalhammer/jwt-cpp";
    description = "A header only library for creating and validating json web tokens in c++";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    sourceProvenance = with lib.sourceTypes;[fromSource];
  };
}
