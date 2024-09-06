{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "radiolib";
  version = "6.6.0";

  src = fetchFromGitHub {
    owner = "jgromes";
    repo = "RadioLib";
    rev = finalAttrs.version;
    hash = "sha256-69elzuGH1z7AnzSp5DZ1y2H3RrXT0k3JFPBJ213Cy8o=";
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
