{
  stdenv,
  fetchurl,
  makeWrapper,
  steam-run,
  lib,
  acceleration ? null, # module compat
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ollama-ipex";
  version = "2.3.0b20250725";

  src = fetchurl {
    url = "https://github.com/ipex-llm/ipex-llm/releases/download/v2.3.0-nightly/ollama-ipex-llm-${finalAttrs.version}-ubuntu.tgz";
    hash = "sha256-zTWGTyiNERLpJDN2hgcHx7AtDMb2JEbjWTAZ3VMMfIc=";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ steam-run ];

  sourceRoot = "ollama-ipex-llm-${finalAttrs.version}-ubuntu";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/ollama-ipex
    cp -r ./* $out/lib/ollama-ipex/

    mkdir -p $out/bin

    runHook postInstall
  '';

  postFixup = ''
    makeWrapper ${steam-run}/bin/steam-run $out/bin/ollama-ipex \
      --prefix LD_LIBRARY_PATH : "$out/lib/ollama-ipex" \
      --add-flags "$out/lib/ollama-ipex/ollama"
  '';

  meta = with lib; {
    description = "Ollama with IPEX-LLM acceleration for Intel GPUs";
    homepage = "https://github.com/ipex-llm/ipex-llm";
    license = licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryBytecode ];
    platforms = platforms.linux;
    mainProgram = "ollama-ipex";
  };
})
