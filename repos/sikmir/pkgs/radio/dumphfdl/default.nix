{ lib, stdenv, fetchFromGitHub, cmake, pkg-config, fftwFloat, glib, libacars, libconfig, liquid-dsp, soapysdr, sqlite, zeromq }:

stdenv.mkDerivation (finalAttrs: {
  pname = "dumphfdl";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "szpajder";
    repo = "dumphfdl";
    rev = "v${finalAttrs.version}";
    hash = "sha256-DfHQdZrns3V7WfzAZaoK2vIvE1o4fBcZ4AvvGNFgrfQ=";
  };

  nativeBuildInputs = [ cmake pkg-config ];

  buildInputs = [ fftwFloat glib libacars libconfig liquid-dsp soapysdr sqlite zeromq ];

  meta = with lib; {
    description = "Multichannel HFDL decoder";
    inherit (finalAttrs.src.meta) homepage;
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
    broken = stdenv.isDarwin;
  };
})
