{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gnsstk,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnsstk-apps";
  version = "14.1.1";

  src = fetchFromGitHub {
    owner = "SGL-UT";
    repo = "gnsstk-apps";
    tag = "v${finalAttrs.version}";
    hash = "sha256-gnw42ebL8hxRq8hX2IvTDwbqKDws9n3jmcSXLvBre8A=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [ gnsstk ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_EXT" true)
    (lib.cmakeFeature "CMAKE_CXX_STANDARD" "14")
  ];

  meta = {
    description = "GNSSTk applications suite";
    homepage = "https://github.com/SGL-UT/gnsstk-apps";
    license = lib.licenses.lgpl3Plus;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
