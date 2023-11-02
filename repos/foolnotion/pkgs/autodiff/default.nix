{ lib, stdenv, fetchFromGitHub, python3Packages, catch2, cmake, eigen }:

stdenv.mkDerivation rec {
  pname = "autodiff";
  version = "v1.0.3";

  src = fetchFromGitHub {
    owner = "autodiff";
    repo = "autodiff";
    rev = "${version}";
    sha256 = "sha256-hdIbEIZrxA5EA3XY4MIazRv3DazUjpuDJRCgq8+kJQg=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ eigen ];
  cmakeFlags = [
    "-DAUTODIFF_BUILD_TESTS=OFF"
    "-DAUTODIFF_BUILD_PYTHON=OFF"
    "-DAUTODIFF_BUILD_EXAMPLES=OFF"
    "-DAUTODIFF_BUILD_DOCS=OFF"
  ];

  meta = with lib; {
    description = "C++17 library that uses modern and advanced programming techniques to enable automatic computation of derivatives in an efficient, easy, and intuitive way.";
    homepage = "https://autodiff.github.io/";
    license = licenses.mit;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
