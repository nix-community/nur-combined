{ lib, stdenv, fetchFromGitHub, cmake, openssl, makeWrapper }:

stdenv.mkDerivation rec {
  pname = "paho.mqtt.c";
  version = "1.3.11";

  src = fetchFromGitHub {
    owner = "eclipse";
    repo = "paho.mqtt.c";
    rev = "v${version}";
    hash = "sha256-TGCWA9tOOx0rCb/XQWqLFbXb9gOyGS8u6o9fvSRS6xI=";
  };

  nativeBuildInputs = [ cmake makeWrapper ];

  buildInputs = [ openssl ];

  cmakeFlags = [ "-DPAHO_WITH_SSL=TRUE" ];

  postFixup = ''
    # for dlopen
    wrapProgram $out/bin/MQTTVersion \
      --prefix LD_LIBRARY_PATH : "$out/lib" \
      --prefix DYLD_LIBRARY_PATH : "$out/lib"
  '';

  meta = with lib; {
    description = "Eclipse Paho MQTT C Client Library";
    homepage = "https://www.eclipse.org/paho/";
    license = licenses.epl20;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
