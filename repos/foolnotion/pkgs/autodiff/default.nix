{ lib, stdenv, fetchFromGitHub, python3Packages, catch2, cmake, eigen }:

stdenv.mkDerivation rec {
  pname = "autodiff";
  version = "v0.6.4";

  src = fetchFromGitHub {
    owner = "autodiff";
    repo = "autodiff";
    rev = "${version}";
    sha256 = "sha256-uBa19dM7VNauWFI4TJNec1gvcDWjGSlFK1tx33vsgIQ=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ catch2 eigen python3Packages.pybind11 ];

  meta = with lib; {
    description = "C++17 library that uses modern and advanced programming techniques to enable automatic computation of derivatives in an efficient, easy, and intuitive way.";
    homepage = "https://autodiff.github.io/";
    license = licenses.mit;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
