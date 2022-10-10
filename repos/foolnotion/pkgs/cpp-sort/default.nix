{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "cppsort";
  version = "1.13.2";

  src = fetchFromGitHub {
    owner = "Morwenn";
    repo = "cpp-sort";
    rev = "${version}";
    sha256 = "sha256-kyZyiAmE1xFpsyp6mQMYaTxQyqn+TMBgf2fqg0xNDis=";
  };

  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    description = "Generic header-only C++14 sorting library.";
    homepage = "https://github.com/Morwenn/cpp-sort";
    license = licenses.mit;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
