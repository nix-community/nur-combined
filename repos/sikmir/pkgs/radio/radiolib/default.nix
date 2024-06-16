{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "radiolib";
  version = "6.5.0";

  src = fetchFromGitHub {
    owner = "jgromes";
    repo = "RadioLib";
    rev = finalAttrs.version;
    hash = "sha256-/s3a8P777cLyjLuSoPD89oh4bOHH4mh6NMadl2VpjpI=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake ];

  meta = {
    description = "Universal wireless communication library for embedded devices";
    homepage = "https://github.com/jgromes/RadioLib";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
