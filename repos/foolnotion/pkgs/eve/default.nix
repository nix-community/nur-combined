{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "eve";
  version = "2022.03.0";

  src = fetchFromGitHub {
    owner = "jfalcou";
    repo = "eve";
    rev = "v${version}";
    sha256 = "sha256-djxjsLaRGM+2afH+HXv1F0lFQyAPUevoOTj3wptpo44=";
  };

  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    description = "EVE - the Expressive Vector Engine in C++20.";
    homepage = "https://github.com/jfalcou/eve";
    license = licenses.mit;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
