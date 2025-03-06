{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  plutovg,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lunasvg";
  version = "3.2.0";

  src = fetchFromGitHub {
    owner = "sammycage";
    repo = "lunasvg";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/DEyiHlZJYctkNqjQECKRbMGwUYTJHtlQrO0aBXf+Oc=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [ plutovg ];

  meta = {
    description = "SVG rendering and manipulation library in C++";
    homepage = "https://github.com/sammycage/lunasvg";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
