{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gqrx-scanner";
  version = "1.0.5";

  src = fetchFromGitHub {
    owner = "neural75";
    repo = "gqrx-scanner";
    rev = "v${finalAttrs.version}";
    hash = "sha256-/MQksngCPr71p+D6qnbK2i/BsrSslGbWqti60rGPjGs=";
  };

  nativeBuildInputs = [ cmake ];

  env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.isDarwin "-DOSX";

  meta = {
    description = "A frequency scanner for Gqrx Software Defined Radio receiver";
    inherit (finalAttrs.src.meta) homepage;
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
