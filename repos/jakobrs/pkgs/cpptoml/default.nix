{ stdenv, lib, cmake, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "cpptoml";
  version = "0.1.1";

  nativeBuildInputs = [ cmake ];

  src = fetchFromGitHub {
    owner = "skystrife";
    repo = "cpptoml";
    rev = "v${version}";
    hash = "sha256:0zlgdlk9nsskmr8xc2ajm6mn1x5wz82ssx9w88s02icz71mcihrx";
  };

  meta = {
    description = "cpptoml is a header-only library for parsing TOML";
    license = lib.licenses.mit;
  };
}
