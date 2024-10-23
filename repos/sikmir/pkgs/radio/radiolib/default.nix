{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "radiolib";
  version = "7.0.2";

  src = fetchFromGitHub {
    owner = "jgromes";
    repo = "RadioLib";
    rev = finalAttrs.version;
    hash = "sha256-m+8Lf/V2ltBoLJX6QNHysFap/EuMlozD9Y0d1eMKH6Y=";
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
