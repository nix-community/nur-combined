{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libnbcompat";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "archiecobbs";
    repo = "libnbcompat";
    tag = finalAttrs.version;
    hash = "sha256-DyBLEp5dNYSQgTzdQkGfLdCtX618EbnVy5FmL75BMdU=";
  };

  nativeBuildInputs = [ autoreconfHook ];

  meta = {
    description = "Portable NetBSD-compatibility library";
    homepage = "https://github.com/archiecobbs/libnbcompat";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
