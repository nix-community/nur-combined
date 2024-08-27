{ lib, stdenv, fetchFromGitHub, python3Packages, catch2, cmake, eigen }:

stdenv.mkDerivation rec {
  pname = "autodiff";
  version = "v1.1.2";

  src = fetchFromGitHub {
    owner = "autodiff";
    repo = "autodiff";
    rev = "${version}";
    sha256 = "sha256-hKIufS5o5tfsbVchwTJxms1n5Im1iTfY3KGWD1s5g9M=";
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
