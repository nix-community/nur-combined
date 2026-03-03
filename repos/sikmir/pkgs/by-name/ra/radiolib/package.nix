{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "radiolib";
  version = "7.6.0";

  src = fetchFromGitHub {
    owner = "jgromes";
    repo = "RadioLib";
    tag = finalAttrs.version;
    hash = "sha256-2dp3Lc22o5JYBIHzPjI1kRlS8qmHD9RXo1UG4VtVUuI=";
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
