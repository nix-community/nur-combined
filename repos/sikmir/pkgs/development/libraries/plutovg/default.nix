{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "plutovg";
  version = "0.0.13";

  src = fetchFromGitHub {
    owner = "sammycage";
    repo = "plutovg";
    tag = "v${finalAttrs.version}";
    hash = "sha256-zmF64qpOwL3QHfp1GznN4TDydjGyhw8IgXYlpCEGXHg=";
  };

  nativeBuildInputs = [ cmake ];

  meta = {
    description = "Tiny 2D vector graphics library in C";
    homepage = "https://github.com/sammycage/plutovg";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
