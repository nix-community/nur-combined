{ lib
, stdenv
, fetchFromGitHub
, cmake
, libcxxCmakeModule ? false
}:

stdenv.mkDerivation rec {
  pname = "cpptoml-cryptocode";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "cryptocode";
    repo = "cpptoml";
    rev = "539965005606a481ae29b723e21aa254d3c29c62";
    hash = "sha256-QVeifGJtuT9h3WmaAHQLPndVqXseUNXC8eImVo4U7HQ=";
  };

  nativeBuildInputs = [
    cmake
  ];

  cmakeFlags = [
    # If this package is built with clang it will attempt to
    # use libcxx via the Cmake find_package interface.
    # The default libcxx stdenv in llvmPackages doesn't provide
    # this and so will fail.
    "-DENABLE_LIBCXX=${if libcxxCmakeModule then "ON" else "OFF"}"
    "-DCPPTOML_BUILD_EXAMPLES=OFF"
  ];

  meta = with lib; {
    description = "C++ TOML configuration library";
    homepage = "https://github.com/cryptocode/cpptoml";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    platforms = platforms.all;
  };
}
