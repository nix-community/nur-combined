{ lib, stdenv, fetchFromGitHub, python3Packages, catch2, cmake, eigen }:

stdenv.mkDerivation rec {
  pname = "autodiff";
  version = "v0.6.12";

  src = fetchFromGitHub {
    owner = "autodiff";
    repo = "autodiff";
    rev = "${version}";
    sha256 = "sha256-pSZtfVvS1B/uRKuV2aHKd3YwFU6zq1hr/99PbQRzJOU=";
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
    broken = true; # marked broken because it requires a cmake version that is not available on 21.11
    #maintainers = with maintainers; [ foolnotion ];
  };
}
