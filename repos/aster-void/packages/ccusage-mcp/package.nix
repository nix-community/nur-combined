{
  stdenv,
  nodejs,
  fetchFromGitHub,
  pnpm,
  pnpmConfigHook,
  fetchPnpmDeps,
  makeBinaryWrapper,
  lib,
  bun,
}: let
  version = "17.2.0";
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "ccusage-mcp";
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

      bun build apps/mcp/src/index.ts --outfile build/index.js --target bun --minify

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out $out/bin $out/share/ccusage-mcp

      cp ./build/index.js $out/share/ccusage-mcp/app.js
      makeWrapper ${lib.getExe bun} $out/bin/ccusage-mcp --add-flags "$out/share/ccusage-mcp/app.js"

      runHook postInstall
    '';

    meta = with lib; {
      description = "Model Context Protocol server that exposes ccusage data to Claude Desktop and other MCP-compatible tools";
      homepage = "https://www.npmjs.com/package/@ccusage/mcp";
      license = licenses.mit;
      maintainers = [];
      platforms = platforms.all;
      mainProgram = "ccusage-mcp";
    };
  })
