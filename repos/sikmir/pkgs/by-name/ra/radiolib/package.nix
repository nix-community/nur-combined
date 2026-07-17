{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "radiolib";
  version = "7.7.1";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "jgromes";
    repo = "RadioLib";
    tag = finalAttrs.version;
    hash = "sha256-/QwQXaTO1LGUGr4ugvw4061m37NgkOXVM5b5nqn8eXk=";
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
