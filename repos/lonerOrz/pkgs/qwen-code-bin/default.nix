{
  lib,
  nodejs,
  fetchurl,
  stdenvNoCC,
  makeWrapper,
}:
let
  owner = "QwenLM";
  repo = "qwen-code";
  asset = "gemini.js";
  version = "0.0.12";
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "qwen-code-bin";
  inherit version;

  src = fetchurl {
    url = "https://github.com/${owner}/${repo}/releases/download/v${version}/${asset}";
    hash = "sha256-QzvlPP8DYK/tOinn5glTZWvjgACP1SrR6V1QgK5FrgU=";
  };

  phases = [
    "installPhase"
    "fixupPhase"
  ];

  # Only allow explicitly listed dependencies to be used during the build phase
  strictDeps = true;

  buildInputs = [
    nodejs
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall

    install -D "$src" "$out/bin/qwen"
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
