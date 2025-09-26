{
  lib,
  nodejs,
  fetchurl,
  stdenvNoCC,
  makeWrapper,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "qwen-code-bin";
  version = "0.0.14-nightly.1";

  src = fetchurl {
    url = "https://github.com/QwenLM/qwen-code/releases/download/v${finalAttrs.version}/gemini.js";
    hash = "sha256-3Jn41KNpa5ZP1vID+0mrKexgsUUBPsiQkEnVxVqi4f0=";
  };

  dontUnpack = true;
  strictDeps = true;

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [
    nodejs
  ];

  installPhase = ''
    runHook preInstall

    cp "$src" ./qwen
    install -D "qwen" "$out/bin/qwen"
    # Suppress deprecation warnings
    wrapProgram "$out/bin/qwen" \
      --set NODE_OPTIONS "--no-deprecation"

    runHook postInstall
  '';

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Coding agent that lives in the digital world";
    homepage = "https://github.com/QwenLM/qwen-code";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ lonerOrz ];
    mainProgram = "qwen";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    sourceProvenance = [ lib.sourceTypes.binaryBytecode ];
  };
})
