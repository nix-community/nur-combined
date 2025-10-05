{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "radiolib";
  version = "7.1.2";

  src = fetchFromGitHub {
    owner = "jgromes";
    repo = "RadioLib";
    tag = finalAttrs.version;
    hash = "sha256-quXQ9J6K8C6eZ8o//fQn16aw/VMWRD+Wvp+VNS/mfCs=";
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
