{
  stdenv,
  nodejs,
  fetchFromGitHub,
  pnpm,
  bun,
  makeWrapper,
  lib,
}: let
  version = "17.1.3";
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "ccusage";
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

      bun build ./apps/ccusage/src/index.ts --outfile build/index.js --target bun --minify

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out $out/share/ccusage $out/bin

      cp build/index.js $out/share/ccusage/app.js
      makeWrapper ${lib.getExe bun} $out/bin/ccusage --add-flags "$out/share/ccusage/app.js"

      runHook postInstall
    '';

    meta = with lib; {
      description = "CLI tool for analyzing Claude Code usage from local JSONL files";
      homepage = "https://www.npmjs.com/package/ccusage";
      license = licenses.mit;
      maintainers = [];
      platforms = platforms.all;
      mainProgram = "ccusage";
    };
  })
