{
  lib,
  rustPlatform,
  fetchFromGitHub,
  cmake,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rumqtt";
  version = "0.20.0";

  src = fetchFromGitHub {
    owner = "bytebeamio";
    repo = "rumqtt";
    tag = "rumqttd-${finalAttrs.version}";
    hash = "sha256-WFhVSFAp5ZIqranLpU86L7keQaReEUXxxGhvikF+TBw=";
  };

  cargoHash = "sha256-UP1uhG+Ow/jN/B8i//vujP7vpoQ5PjYGCrXs0b1bym4=";

  nativeBuildInputs = [ cmake ];

  __darwinAllowLocalNetworking = true;

  meta = {
    description = "The MQTT ecosystem in rust";
    homepage = "https://github.com/bytebeamio/rumqtt";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "rumqttd";
  };
})
