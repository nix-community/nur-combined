{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation (finalAttrs: {
  pname = "gpstk";
  version = "8.0.0";

  src = fetchFromGitHub {
    owner = "SGL-UT";
    repo = "GPSTk";
    rev = "v${finalAttrs.version}";
    hash = "sha256-kauRkx7KjVFdjl3JPiCxeuuVGVJ69e87RZQhepRrsWY=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [ "-DBUILD_EXT=ON" ];

  meta = with lib; {
    description = "Toolkit for developing GPS applications";
    inherit (finalAttrs.src.meta) homepage;
    license = licenses.lgpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
})
