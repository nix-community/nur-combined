{
  stdenv,
  cmake,
  zlib,
  lib,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "cnpy";
  version = "0-unstable-2018-05-31";

  src = fetchFromGitHub {
    owner = "rogersce";
    repo = "cnpy";
    rev = "4e8810b1a8637695171ed346ce68f6984e585ef4";
    hash = "sha256-NMPDpeNoqvqAhwQk4J+TFw+BtNLI4R+CXpzXQ6hB/LU=";
  };
  patches = [ ./pc.patch ];
  cmakeFlags = [ (lib.cmakeFeature "CMAKE_POLICY_VERSION_MINIMUM" "3.5") ];
  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [ zlib ];
}
