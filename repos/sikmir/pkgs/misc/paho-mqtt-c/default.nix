{ lib, stdenv, fetchFromGitHub, cmake, openssl }:

stdenv.mkDerivation rec {
  pname = "paho.mqtt.c";
  version = "1.3.11";

  src = fetchFromGitHub {
    owner = "eclipse";
    repo = "paho.mqtt.c";
    rev = "v${version}";
    hash = "sha256-TGCWA9tOOx0rCb/XQWqLFbXb9gOyGS8u6o9fvSRS6xI=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [ openssl ];

  cmakeFlags = [ "-DPAHO_WITH_SSL=TRUE" ];

  meta = with lib; {
    description = "Eclipse Paho MQTT C Client Library";
    inherit (src.meta) homepage;
    license = licenses.epl20;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
