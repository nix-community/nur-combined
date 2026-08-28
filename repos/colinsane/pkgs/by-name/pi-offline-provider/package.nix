{
  lib,
  llama-cpp,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation {
  pname = "pi-offline-provider";
  version = "0.1.0";

  src = ./.;

  postPatch = ''
    substituteInPlace ./index.ts \
      --replace-fail '@llama_server@' ${lib.getExe' llama-cpp "llama-server"}
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -R package.json index.ts $out/

    runHook postInstall
  '';

  meta = {
    description = "Pi provider that starts a local llama.cpp server for offline LLM inference";
    maintainers = with lib.maintainers; [ colinsane ];
  };
}
