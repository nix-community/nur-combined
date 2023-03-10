{ lib, stdenv, rustPlatform, fetchFromGitHub, cmake, Security }:

rustPlatform.buildRustPackage rec {
  pname = "rumqtt";
  version = "0.13.0";

  src = fetchFromGitHub {
    owner = "bytebeamio";
    repo = "rumqtt";
    rev = "rumqttd-${version}";
    hash = "sha256-MXQUuobIuR9Ij0mG5MwQx8vbTWl2Ch44CbzVpN4n42k=";
  };

  cargoHash = "sha256-xAEeGR7ZOS6euzWw0WnU1OpUZJlWpD6I3/eaEt228o4=";

  nativeBuildInputs = [ cmake ];

  buildInputs = lib.optional stdenv.isDarwin Security;

  meta = with lib; {
    description = "The MQTT ecosystem in rust";
    homepage = "https://github.com/bytebeamio/rumqtt";
    license = licenses.asl20;
    maintainers = [ maintainers.sikmir ];
  };
}
