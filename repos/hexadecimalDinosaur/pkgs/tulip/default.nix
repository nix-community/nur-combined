{
  lib,
  buildEnv,
  tulip-api,
  tulip-assembler,
  tulip-enricher,
  tulip-flagids,
  tulip-frontend
}:
buildEnv rec {
  name = "${pname}-${version}";
  pname = "tulip";
  version = "1.0.1-2025.07.03.unstable";
  paths = [
    tulip-api
    tulip-assembler
    tulip-enricher
    tulip-flagids
    tulip-frontend
  ];

  meta = {
    description = "Network analysis tool for Attack Defence CTF";
    homepage = "https://github.com/OpenAttackDefenseTools/tulip/";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ivyfanchiang ];
    mainProgram = "tulip-api";
  };
}
