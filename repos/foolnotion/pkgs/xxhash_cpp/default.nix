{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "xxhash_cpp";
  version = "0.8.1";

  src = fetchFromGitHub {
    owner = "RedSpah";
    repo = "xxhash_cpp";
    rev = "${version}";
    sha256 = "sha256-w0tQxwU4FxTWKS87KGIYU1tsrMNd7u1Hlg/Rf+VvRg0=";
  };

  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    description = "C++ port of the xxhash library.";
    homepage = "https://github.com/RedSpah/xxhash_cpp";
    license = licenses.bsd2;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
