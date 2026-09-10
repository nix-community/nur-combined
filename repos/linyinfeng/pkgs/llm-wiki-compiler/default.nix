{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  nix-update-script,
}:

buildNpmPackage rec {
  pname = "llm-wiki-compiler";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "atomicstrata";
    repo = "llm-wiki-compiler";
    rev = "v${version}";
    hash = "sha256-sy0IWmJse088CkI21YPCtEi5wamDFnoyw01rt/7byOY=";
  };

  npmDepsHash = "sha256-z+QjnWbKJ8kr+W92c5xOif2npSmNuOpFtlr90GxSrPs=";

  npmBuildScript = "build";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/lib/node_modules/llm-wiki-compiler
    cp -r . $out/lib/node_modules/llm-wiki-compiler/
    ln -s "$out/lib/node_modules/llm-wiki-compiler/dist/cli.js" "$out/bin/llmwiki"
    runHook postInstall
  '';

  passthru = {
    updateScriptEnabled = true;
    updateScript = nix-update-script { attrPath = pname; };
  };

  meta = {
    description = "Compile your knowledge base into a single-page LLM context";
    homepage = "https://github.com/atomicstrata/llm-wiki-compiler";
    license = lib.licenses.mit;
    mainProgram = "llmwiki";
    maintainers = with lib.maintainers; [ yinfeng ];
  };
}
