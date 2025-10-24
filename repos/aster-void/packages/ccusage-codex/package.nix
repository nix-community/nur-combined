{
  stdenv,
  nodejs,
  fetchFromGitHub,
  pnpm,
  makeWrapper,
  lib,
  bun,
}: let
  version = "17.1.3";
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "ccusage-codex";
    inherit version;

    src = fetchFromGitHub {
      owner = "ryoppippi";
      repo = "ccusage";
      tag = "v${version}";
      hash = "sha256-s/0tki1xD7dIawGmURlvJGf5C+jhL6HrZLUo5C1bV98=";
    };

    pnpmDeps = pnpm.fetchDeps {
      inherit (finalAttrs) pname version src;
      fetcherVersion = 2;
      hash = "sha256-zUh/aBRo6xk05NgqSO9WyDyFPQEiHqMzQ8i4Y5XBGgA=";
    };

    nativeBuildInputs = [
      nodejs
      pnpm.configHook
      bun
      makeWrapper
    ];

    pnpmInstallFlags = ["--ignore-scripts"];

    buildPhase = ''
      runHook preBuild

      bun build apps/codex/src/index.ts --outfile build/index.js --target bun --minify

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out $out/app $out/bin

      cp build/index.js $out/app/
      makeWrapper ${lib.getExe bun} $out/bin/ccusage-codex --add-flags "$out/app/index.js"

      runHook postInstall
    '';

    meta = with lib; {
      description = "CLI tool for analyzing Codex CLI usage from local JSONL files";
      homepage = "https://www.npmjs.com/package/@ccusage/codex";
      license = licenses.mit;
      maintainers = [];
      platforms = platforms.all;
      mainProgram = "ccusage-codex";
    };
  })
