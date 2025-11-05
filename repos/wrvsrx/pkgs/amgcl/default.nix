{
  stdenv,
  cmake,
  lib,
  source,
}:
stdenv.mkDerivation {
  inherit (source) pname src;
  version = "1.4.5-unstable-" + source.date;
  nativeBuildInputs = [ cmake ];
  cmakeFlags = [ (lib.cmakeFeature "CMAKE_POLICY_VERSION_MINIMUM" "3.5") ];
}
