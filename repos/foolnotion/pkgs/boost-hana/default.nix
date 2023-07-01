{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "boost-hana";
  version = "1.7.0";

  src = fetchFromGitHub {
    owner = "boostorg";
    repo = "hana";
    rev = "v${version}";
    sha256 = "sha256-4AwlO+DYQgnCmYaWA7B+uKB7BVIajS5p4uG7zkcp53U=";
  };

  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    description = "Header-only library for C++ metaprogramming suited for computations on both types and values";
    homepage = "https://github.com/boostorg/hana";
    license = licenses.mit;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
