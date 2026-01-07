{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  cmake,
  geos,
  jsoncpp,
  libgeotiff,
  libjpeg,
  libtiff,
  makeWrapper,
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

  patches = [
    # Fixed build error gcc version 15.0.1
    (fetchpatch {
      url = "https://github.com/ossimlabs/ossim/commit/13b9fa9ae54f79a7e7728408de6246e00d38f399.patch";
      hash = "sha256-AKzOT+JurB/54gvzn2a5amw+uIupaNxssnEhc8CSfPM=";
    })
  ];

  nativeBuildInputs = [
    cmake
    makeWrapper
  ];

  buildInputs = [
    geos
    jsoncpp
    libgeotiff
    libjpeg
    libtiff
  ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_OSSIM_TESTS" false)
    (lib.cmakeFeature "CMAKE_POLICY_VERSION_MINIMUM" "3.10")
  ];

  postInstall = ''
    for binary in $out/bin/ossim-*; do
      wrapProgram $binary \
        --prefix LD_LIBRARY_PATH ":" $out/lib
    done
  '';

  meta = {
    description = "Open Source Software Image Map library";
    homepage = "https://trac.osgeo.org/ossim";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
