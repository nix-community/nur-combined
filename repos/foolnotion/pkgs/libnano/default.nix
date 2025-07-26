{ lib, stdenv, fetchFromGitHub, cmake, eigen, writeShellScriptBin }:

stdenv.mkDerivation rec {
  pname = "libnano";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "accosmin-org";
    repo = "libnano";
    rev = "b3c2f3bd6c4bae79177df9b7cf220556d1c9de7e";
    sha256 = "sha256-hoGX3x+/0RnWGQxkF9fFCtbKl1r9DeyvVffi3QQ+XKo=";
  };

  nativeBuildInputs = [
    cmake
    (writeShellScriptBin "git" ''
      echo "${src.rev}"
    '')
  ];
  buildInputs = [ eigen ];

  cmakeFlags = [
    "-DCMAKE_CXX_FLAGS=-march=x86-64-v3"
    "-DNANO_BUILD_CMD_APP=OFF"
    "-DNANO_BUILD_TESTS=OFF"
  ];

  meta = with lib; {
    description = "Extensive collection of numerical optimization algorithms in C++";
    homepage = "https://github.com/accosmin-org/libnano";
    license = licenses.mit;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
