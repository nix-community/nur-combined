{ lib, stdenv, rustPlatform, fetchFromGitHub, cmake, Security }:

rustPlatform.buildRustPackage rec {
  pname = "rumqtt";
  version = "0.15.0";

  src = fetchFromGitHub {
    owner = "bytebeamio";
    repo = "rumqtt";
    rev = "rumqttd-${version}";
    hash = "sha256-Tl+ViUn7LrJY+iQu6wdNN6h1Y6KKUOrnIaRR3uvvjiw=";
  };

  cargoHash = "sha256-I9YcgVEfOsaXd3+B+CskdayXVq4mvznNXEAa2p3+zUQ=";

  nativeBuildInputs = [ cmake ];

  buildInputs = lib.optional stdenv.isDarwin Security;

  meta = with lib; {
    description = "The MQTT ecosystem in rust";
    homepage = "https://github.com/bytebeamio/rumqtt";
    license = licenses.asl20;
    maintainers = [ maintainers.sikmir ];
  };
}
