{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "cppsort";
  version = "1.11.0";

  src = fetchFromGitHub {
    owner = "Morwenn";
    repo = "cpp-sort";
    rev = "${version}";
    sha256 = "sha256-dB5Un+LOYtKsY5XLUPO13DVYGu/tIfafJOmsBUo63r0=";
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
