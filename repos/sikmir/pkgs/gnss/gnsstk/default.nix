{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnsstk";
  version = "14.3.0";

  src = fetchFromGitHub {
    owner = "SGL-UT";
    repo = "gnsstk";
    rev = "v${finalAttrs.version}";
    hash = "sha256-7dD9GDW/1j2f0Tzetr6Fmbnkl1WDnX82eiaZpO8ngd8=";
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

  meta = {
    description = "GNSSTk libraries";
    inherit (finalAttrs.src.meta) homepage;
    license = lib.licenses.lgpl3Plus;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
