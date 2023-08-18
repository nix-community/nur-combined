{ lib, stdenv, rustPlatform, fetchFromGitHub, cmake, Security }:

rustPlatform.buildRustPackage rec {
  pname = "rumqtt";
  version = "0.17.0";

  src = fetchFromGitHub {
    owner = "bytebeamio";
    repo = "rumqtt";
    rev = "rumqttd-${version}";
    hash = "sha256-hxmbcTrwHIM4/k7gzrRA6hpmgVgP7cJ3mM6Ge+6Ong8=";
  };

  cargoHash = "sha256-ruk9+ESl9o2d1CeLM3IDXGlx9osH20e2SwAGXKXt3OY=";

  nativeBuildInputs = [ cmake ];

  buildInputs = lib.optional stdenv.isDarwin Security;

  meta = with lib; {
    description = "The MQTT ecosystem in rust";
    homepage = "https://github.com/bytebeamio/rumqtt";
    license = licenses.asl20;
    maintainers = [ maintainers.sikmir ];
  };
}
