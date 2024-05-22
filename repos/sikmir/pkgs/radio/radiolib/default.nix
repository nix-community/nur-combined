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

  meta = with lib; {
    description = "Universal wireless communication library for embedded devices";
    inherit (finalAttrs.src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
})
