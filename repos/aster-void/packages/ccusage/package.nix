{
  stdenv,
  nodejs,
  fetchFromGitHub,
  pnpm,
  pnpmConfigHook,
  fetchPnpmDeps,
  bun,
  makeBinaryWrapper,
  lib,
}: let
  version = "17.2.0";
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "ccusage";
    inherit version;

    src = fetchFromGitHub {
      owner = "ryoppippi";
      repo = "ccusage";
      tag = "v${version}";
      hash = "sha256-3EHiNPQlvLQgkFRSGWhLuo31PVaNBGhpc9pa3VcR5tw=";
    };

    pnpmDeps = fetchPnpmDeps {
      inherit (finalAttrs) pname version src;
      fetcherVersion = 2;
      hash = "sha256-nOHptc1Ov6YTHMcU3HDb2BSdcceWeM2rX+XAKiowOxM=";
    };

    nativeBuildInputs = [
      nodejs
      pnpm
      pnpmConfigHook
      bun
      makeBinaryWrapper
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
