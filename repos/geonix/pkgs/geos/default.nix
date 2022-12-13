{ lib
, stdenv
, callPackage
, fetchurl
, fetchpatch
, cmake }:

stdenv.mkDerivation (finalAttrs: {
  pname = "geos";
  version = "3.11.1";

  src = fetchurl {
    url = "https://download.osgeo.org/geos/${finalAttrs.pname}-${finalAttrs.version}.tar.bz2";
    hash = "sha256-bQ6zz6n5LZR3Mcx18XUDVrO9/AfqAgVT2vavHHaOC+I=";
  };

  nativeBuildInputs = [ cmake ];

  doCheck = true;

  passthru.tests = {
    geos = callPackage ./tests.nix { };
  };

  meta = with lib; {
    description = "C++ port of the Java Topology Suite (JTS)";
    homepage = "https://trac.osgeo.org/geos";
    license = licenses.lgpl21Only;
    maintainers = with lib.maintainers; [
      willcohen
    ];
  };
})
