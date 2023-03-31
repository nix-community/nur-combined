{ lib, stdenv, rustPlatform, fetchFromGitHub, cmake, Security }:

rustPlatform.buildRustPackage rec {
  pname = "rumqtt";
  version = "0.14.0";

  src = fetchFromGitHub {
    owner = "bytebeamio";
    repo = "rumqtt";
    rev = "rumqttd-${version}";
    hash = "sha256-Ifc5dxSOnR0JWUTwC5JeOQk6ttTjeIFWL9p/Hmyw7Oc=";
  };

  cargoHash = "sha256-KON1NEyGl7WMqBWo8suSOP55ZpccU5myKoPuyJPw1QU=";

  nativeBuildInputs = [ cmake ];

  buildInputs = lib.optional stdenv.isDarwin Security;

  meta = with lib; {
    description = "The MQTT ecosystem in rust";
    homepage = "https://github.com/bytebeamio/rumqtt";
    license = licenses.asl20;
    maintainers = [ maintainers.sikmir ];
  };
}
