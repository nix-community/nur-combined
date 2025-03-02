{ lib, stdenv, fetchFromGitHub, cmake, eigen, writeShellScriptBin }:

stdenv.mkDerivation rec {
  pname = "libnano";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "accosmin-org";
    repo = "libnano";
    rev = "c93a223209089a35fca99bc39ef4fc9cc7e40a3c";
    sha256 = "sha256-P2JLLjuVl0QFEVzqykPlLFJ8pIcECX5HTBqyf69Mls0=";
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
