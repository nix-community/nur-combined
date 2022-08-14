{ lib, stdenv, fetchFromGitHub, python3Packages, catch2, cmake, eigen }:

stdenv.mkDerivation rec {
  pname = "autodiff";
  version = "v0.6.8";

  src = fetchFromGitHub {
    owner = "autodiff";
    repo = "autodiff";
    rev = "${version}";
    sha256 = "sha256-n89UNoY3x8on4H/PRhLbRQm+GVoDSHhf38BmDz43TMs=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ catch2 eigen python3Packages.pybind11 ];

  meta = with lib; {
    description = "C++17 library that uses modern and advanced programming techniques to enable automatic computation of derivatives in an efficient, easy, and intuitive way.";
    homepage = "https://autodiff.github.io/";
    license = licenses.mit;
    platforms = platforms.all;
    broken = true; # marked broken because it requires a cmake version that is not available on 21.11
    #maintainers = with maintainers; [ foolnotion ];
  };
}
