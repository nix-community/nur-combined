{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "ioxy";
  version = "0-unstable-2023-08-20";

  src = fetchFromGitHub {
    owner = "NVISOsecurity";
    repo = "IOXY";
    rev = "6f1d0ffc02cde306caa837713f9a9f81352f13cf";
    hash = "sha256-j3qKlR0dwu0ZHc38JMGUjwVpN2s16ZIiRU8W+lI/X0s=";
  };

  sourceRoot = "${finalAttrs.src.name}/ioxy";

  vendorHash = "sha256-VWw9yuwNnJYvIvl6ov24An867koyzPPbqNg0VIXCJiM=";

  meta = {
    description = "MQTT intercepting proxy";
    homepage = "https://github.com/NVISOsecurity/IOXY";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "ioxy";
  };
})
