{ lib, stdenv, fetchFromGitHub, fetchpatch, cmake }:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnsstk";
  version = "14.0.0";

  src = fetchFromGitHub {
    owner = "SGL-UT";
    repo = "gnsstk";
    rev = "v${finalAttrs.version}";
    hash = "sha256-IRwhFlO9j9pAG7ZhXZz+v3nfMoSlbtm1kwrQABAIV4Y=";
  };

  patches = [
    # Fix compilation with GCC13
    (fetchpatch {
      url = "https://github.com/SGL-UT/gnsstk/pull/21/commits/16c2c7e5b8dc80bb0eb46792fcb1f6e3dcbffbf4.patch";
      hash = "sha256-mIczf1OiHWl+poOulFPLSbNBu4ES8HNjhjOatACaAgI=";
    })
  ];

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_EXT" true)
    (lib.cmakeFeature "CMAKE_CXX_STANDARD" "14")
  ];

  meta = with lib; {
    description = "GNSSTk libraries";
    inherit (finalAttrs.src.meta) homepage;
    license = licenses.lgpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
})
