{
  stdenv,
  cmake,
  lib,
  source,
}:
stdenv.mkDerivation {
  inherit (source) pname src;
  version = "0-unstable-" + source.date;
  patches = [ ./pc.patch ];
  nativeBuildInputs = [ cmake ];
  cmakeFlags = [ (lib.cmakeFeature "CMAKE_POLICY_VERSION_MINIMUM" "3.5") ];
}
