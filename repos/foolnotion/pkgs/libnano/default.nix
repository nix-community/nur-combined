{ lib, stdenv, fetchFromGitHub, cmake, eigen, writeShellScriptBin }:

stdenv.mkDerivation rec {
  pname = "libnano";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "accosmin-org";
    repo = "libnano";
    rev = "1bc529dd9c80755c4e29e58a28a5449d7ef7a41a";
    sha256 = "sha256-GgOFY/gJQl18m/4oIQPoxhF5v5bHW3yn97oFwWNgTLw=";
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
