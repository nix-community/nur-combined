{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "radiolib";
  version = "7.1.1";

  src = fetchFromGitHub {
    owner = "jgromes";
    repo = "RadioLib";
    tag = finalAttrs.version;
    hash = "sha256-UO6a/DCmJEDdKpGDjw1OFtS2ee4XagBxSjwbfbw6obs=";
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
