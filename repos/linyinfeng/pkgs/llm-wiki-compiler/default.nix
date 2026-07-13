{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  nix-update-script,
}:

buildNpmPackage rec {
  pname = "llm-wiki-compiler";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "atomicstrata";
    repo = "llm-wiki-compiler";
    rev = "v${version}";
    hash = "sha256-ZcOFVJ3svlBeSjGqP2xjm3LREwU8t++JXaagUgbu9zU=";
  };

  npmDepsHash = "sha256-Fk3sbT+EGCzjtXyvqb0rrg4w9Hyvv7OaPtvQjaAayJ0=";

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
