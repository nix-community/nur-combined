{ lib, stdenv, rustPlatform, fetchFromGitHub, cmake, Security }:

rustPlatform.buildRustPackage rec {
  pname = "rumqtt";
  version = "0.12.3";

  src = fetchFromGitHub {
    owner = "bytebeamio";
    repo = "rumqtt";
    rev = "rumqttd-${version}";
    hash = "sha256-dcTMfZFK5Jza+ewcBcsGmBN3yGAtao5DEU9poimulVo=";
  };

  cargoHash = "sha256-hpxjXLQY80G9c6uza2T2e8eG5MH9rEbCa/I1u2AbMt4=";

  nativeBuildInputs = [ cmake ];

  buildInputs = lib.optional stdenv.isDarwin Security;

  meta = with lib; {
    description = "The MQTT ecosystem in rust";
    homepage = "https://github.com/bytebeamio/rumqtt";
    license = licenses.asl20;
    maintainers = [ maintainers.sikmir ];
  };
}
