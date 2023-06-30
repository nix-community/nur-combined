{ lib, stdenv, fetchFromGitHub, cmake, eigen, writeShellScriptBin }:

stdenv.mkDerivation rec {
  pname = "libnano";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "accosmin-org";
    repo = "libnano";
    rev = "7b97a5e3cec630542ac21f51eb5b37404ff8f53d";
    sha256 = "sha256-QBylHxaJbaMo4GFnQmYPoZpq1EfUqrnMSMDG4bSr+xM=";
  };

  nativeBuildInputs = [
    cmake
    (writeShellScriptBin "git" ''
      echo "${src.rev}"
    '')
  ];
  buildInputs = [ eigen ];

  cmakeFlags = [
    "-DNANO_BUILD_CMD_APP=ON"
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
