{
  lib,
  rustPlatform,
  fetchFromGitHub,
  cmake,
}:

rustPlatform.buildRustPackage rec {
  pname = "rumqtt";
  version = "0.19.0";

  src = fetchFromGitHub {
    owner = "bytebeamio";
    repo = "rumqtt";
    tag = "rumqttd-${version}";
    hash = "sha256-3rDnJ1VsyGBDhjOq0Rd55WI1EbIo+17tcFZCoeJB3Kc=";
  };

  cargoPatches = [ ./cargo-lock.patch ];
  useFetchCargoVendor = true;
  cargoHash = "sha256-/OUSTfpjqTily2b2RNZEfmHdKHSQo7lQsGwqW08vPnc=";

  nativeBuildInputs = [ cmake ];

  meta = {
    description = "The MQTT ecosystem in rust";
    homepage = "https://github.com/bytebeamio/rumqtt";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
