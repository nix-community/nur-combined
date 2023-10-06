{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnsstk";
  version = "14.0.0";

  src = fetchFromGitHub {
    owner = "SGL-UT";
    repo = "gnsstk";
    rev = "v${finalAttrs.version}";
    hash = "sha256-IRwhFlO9j9pAG7ZhXZz+v3nfMoSlbtm1kwrQABAIV4Y=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_EXT" true)
  ];

  meta = with lib; {
    description = "GNSSTk libraries";
    inherit (finalAttrs.src.meta) homepage;
    license = licenses.lgpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
})
