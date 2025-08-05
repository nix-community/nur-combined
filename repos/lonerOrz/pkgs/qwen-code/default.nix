{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  fetchNpmDeps,
  nix-update-script,
}:

buildNpmPackage (finalAttrs: {
  pname = "qwen-code";
  version = "0.0.4";

  src = fetchFromGitHub {
    owner = "QwenLM";
    repo = "qwen-code";
    rev = "v${finalAttrs.version}";
    hash = "sha256-zVbgJaufJNYxsNuX2JH3tgQeBPalzhgf43sNaifzjYI=";
  };

  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) src;
    hash = "sha256-wQokEy8kbh81xVbuEAtK/YAKIL+u9gLT1utB5YINupE=";
  };

  buildPhase = ''
    runHook preBuild

    npm run generate
    npm run bundle

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -r bundle/* $out/
    substituteInPlace $out/gemini.js --replace '/usr/bin/env node' "$(type -p node)"
    ln -s $out/gemini.js $out/bin/qwen

    runHook postInstall
  '';

  meta = {
    description = "Qwen-code is a coding agent that lives in digital world";
    homepage = "https://github.com/QwenLM/qwen-code";
    mainProgram = "qwen";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ lonerOrz ];
  };
})
