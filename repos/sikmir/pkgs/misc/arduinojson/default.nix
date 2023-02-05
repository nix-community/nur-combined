{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "arduinojson";
  version = "6.20.0";

  src = fetchFromGitHub {
    owner = "bblanchon";
    repo = "ArduinoJson";
    rev = "v${version}";
    hash = "sha256-oRqQMc4FpX7bxVDfZhO6ZvwrWEAlY2T4tejIRfklTrs=";
  };

  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    description = "JSON library for Arduino and embedded C++";
    homepage = "https://arduinojson.org/";
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
