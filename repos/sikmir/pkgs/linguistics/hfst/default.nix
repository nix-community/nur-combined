{ lib, stdenv, fetchFromGitHub, autoreconfHook
, bison, flex, foma, pkg-config, icu, zlib }:

stdenv.mkDerivation rec {
  pname = "hfst";
  version = "3.16.0";

  src = fetchFromGitHub {
    owner = "hfst";
    repo = "hfst";
    rev = "v${version}";
    hash = "sha256-2ST0s08Pcp+hTn7rUTgPE1QkH6PPWtiuFezXV3QW0kU=";
  };

  nativeBuildInputs = [ autoreconfHook bison flex pkg-config ];

  buildInputs = [ foma icu zlib ];

  configureFlags = [
    "--with-foma-upstream=true"
  ];

  enableParallelBuilding = true;

  meta = with lib; {
    description = "Helsinki Finite-State Technology (library and application suite)";
    homepage = "https://hfst.github.io";
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
