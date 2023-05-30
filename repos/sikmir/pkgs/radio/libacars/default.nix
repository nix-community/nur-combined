{ lib, stdenv, fetchFromGitHub, cmake, libxml2, zlib }:

stdenv.mkDerivation (finalAttrs: {
  pname = "libacars";
  version = "2.1.4";

  src = fetchFromGitHub {
    owner = "szpajder";
    repo = "libacars";
    rev = "v${finalAttrs.version}";
    hash = "sha256-uOIAGCcCUhc2RsCWOhTVGPQBNpLQMqs0vpXJ5/SS9sE=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [ libxml2 zlib ];

  cmakeFlags = [ "-DCMAKE_INSTALL_LIBDIR=lib" ];

  meta = with lib; {
    description = "A library for decoding various ACARS message payloads";
    inherit (finalAttrs.src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
})
