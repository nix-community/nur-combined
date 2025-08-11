{
  buildEnv,
  tulip-api,
  tulip-assembler,
  tulip-enricher,
  tulip-flagids,
  tulip-frontend
}:
buildEnv {
  name = "tulip";
  pname = "tulip";
  version = "1.0.1-2025.07.03.unstable";
  paths = [
    tulip-api
    tulip-assembler
    tulip-enricher
    tulip-flagids
    tulip-frontend
  ];
}
