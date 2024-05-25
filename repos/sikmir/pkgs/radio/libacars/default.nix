{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  libxml2,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libacars";
  version = "2.2.0";

  src = fetchFromGitHub {
    owner = "szpajder";
    repo = "libacars";
    rev = "v${finalAttrs.version}";
    hash = "sha256-2n1tuKti8Zn5UzQHmRdvW5Q+x4CXS9QuPHFQ+DFriiE=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    libxml2
    zlib
  ];

  cmakeFlags = [ (lib.cmakeFeature "CMAKE_INSTALL_LIBDIR" "lib") ];

  meta = {
    description = "A library for decoding various ACARS message payloads";
    inherit (finalAttrs.src.meta) homepage;
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
