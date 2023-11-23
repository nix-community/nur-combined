{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "cpp-flux";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "tcbrindle";
    repo = "flux";
    rev = "1c128b50af95fc39b6683d437f9210239e219836";
    hash = "sha256-WFHju4hguuuoodCCUHnhPvF4z4YsWSkGqH0fqt+iQ+c=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    "-DFLUX_BUILD_EXAMPLES=OFF"
    "-DFLUX_BUILD_TESTS=OFF"
  ];

  meta = with lib; {
    description = "A C++20 library for sequence-orientated programming";
    homepage = "https://github.com/tcbrindle/flux";
    license = licenses.boost;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
