{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  geos,
  jsoncpp,
  libgeotiff,
  libjpeg,
  libtiff,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ossim";
  version = "2.12.0";

  src = fetchFromGitHub {
    owner = "ossimlabs";
    repo = "ossim";
    tag = finalAttrs.version;
    hash = "sha256-zmyzHEhf/JPBBP7yJyxyKHkJH5psRSl3h8ZcOJ7dr7o=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    geos
    jsoncpp
    libgeotiff
    libjpeg
    libtiff
  ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_OSSIM_APPS" false)
    (lib.cmakeBool "BUILD_OSSIM_TESTS" false)
    (lib.cmakeFeature "CMAKE_POLICY_VERSION_MINIMUM" "3.10")
  ];

  meta = {
    description = "Open Source Software Image Map library";
    homepage = "https://trac.osgeo.org/ossim";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
