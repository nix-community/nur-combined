{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  cmake,
  Security,
}:

rustPlatform.buildRustPackage rec {
  pname = "rumqtt";
  version = "0.19.0";

  src = fetchFromGitHub {
    owner = "bytebeamio";
    repo = "rumqtt";
    rev = "rumqttd-${version}";
    hash = "sha256-3rDnJ1VsyGBDhjOq0Rd55WI1EbIo+17tcFZCoeJB3Kc=";
  };

  cargoHash = "sha256-a6HVcaL6OKIK0h3yuUFDlPASNRciOdW09uXoewld4F8=";

  nativeBuildInputs = [ cmake ];

  buildInputs = lib.optional stdenv.isDarwin Security;

  meta = {
    description = "The MQTT ecosystem in rust";
    homepage = "https://github.com/bytebeamio/rumqtt";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
