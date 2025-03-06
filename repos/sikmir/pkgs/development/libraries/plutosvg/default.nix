{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  plutovg,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "plutosvg";
  version = "0.0.6";

  src = fetchFromGitHub {
    owner = "sammycage";
    repo = "plutosvg";
    tag = "v${finalAttrs.version}";
    hash = "sha256-BpxHVD4P4ZQ9pAvhBHjz9ns7EEsnFqvUEyDKcM2oJps=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [ plutovg ];

  meta = {
    description = "Tiny SVG rendering library in C";
    homepage = "https://github.com/sammycage/plutosvg";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
