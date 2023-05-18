{ lib
, stdenv
, fetchFromGitHub
, cmake
, ncurses
, mbelib
, libsndfile
, itpp
, pulseaudio
, portaudioSupport ? true
, portaudio ? null
}:

assert portaudioSupport -> portaudio != null;

stdenv.mkDerivation rec {
  pname = "dsd-fme";
  version = "2023-05-17";

  src = fetchFromGitHub {
    owner = "lwvmobile";
    repo = "dsd-fme";
    rev = "ae58fabb7285f6a8f0a18ea3988a0d0c99ab4181";
    sha256 = "sha256-q0OMGbIy7hoRJnmKYlmZcHOj9r8UBTSC/tAN/S2ni0U=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [
    ncurses
    mbelib
    libsndfile
    pulseaudio
    itpp
  ] ++ lib.optionals portaudioSupport [ portaudio ];

  doCheck = true;

  meta = with lib; {
    description = "Digital Speech Decoder - Florida Man Edition";
    longDescription = ''
      DSD-FME is an evolution of the original DSD project from 'DSD Author' using the base code of szechyjs
    '';
    homepage = "https://github.com/lwvmobile/dsd-fme";
    license = licenses.gpl2;
  };
}
