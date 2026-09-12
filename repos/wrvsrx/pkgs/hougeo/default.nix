{
  stdenv,
  cmake,
  lib,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "hougeo";
  version = "0-unstable-2015-10-31";

  src = fetchFromGitHub {
    owner = "nyue";
    repo = "hougeo";
    rev = "7e48d2bda0f94fc96b2d8b2917d5ef306ba83c97";
    hash = "sha256-QbPT7oJH835hfdP+o2ON9gQliuktDu4vmS5zzyG8Wfg=";
  };
  patches = [ ./pc.patch ];
  nativeBuildInputs = [ cmake ];
  cmakeFlags = [ (lib.cmakeFeature "CMAKE_POLICY_VERSION_MINIMUM" "3.5") ];
}
