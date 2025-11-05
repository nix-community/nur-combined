{
  stdenv,
  cmake,
  zlib,
  lib,
  source,
}:
stdenv.mkDerivation {
  inherit (source) pname src;
  version = "0-unstable-" + source.date;
  patches = [ ./pc.patch ];
  cmakeFlags = [ (lib.cmakeFeature "CMAKE_POLICY_VERSION_MINIMUM" "3.5") ];
  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [ zlib ];
}
