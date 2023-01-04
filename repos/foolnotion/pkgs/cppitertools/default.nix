{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "cppitertools";
  version = "2.1";

  src = fetchFromGitHub {
    owner = "ryanhaining";
    repo = "cppitertools";
    rev = "add5acc932dea2c78acd80747bab71ec0b5bce27";
    sha256 = "sha256-MKyiitK4d+gTtSdd8nlIy4KUVs5ZjdKMn73VoTTvga0=";
  };

  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    description = "Range-based for loop add-ons inspired by the Python builtins and itertools library";
    homepage = "https://github.com/ryanhaining/cppitertools";
    license = licenses.bsd2;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
