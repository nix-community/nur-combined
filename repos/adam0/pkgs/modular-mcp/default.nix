{
  lib,
  stdenv,
  fetchFromGitHub,
  bun,
  makeWrapper,
  nodejs-slim,
}: let
  inherit
    (lib)
    getExe
    makeBinPath
    ;

  pname = "modular-mcp";
  version = "0.0.10";

  src = fetchFromGitHub {
    owner = "d-kimuson";
    repo = pname;
    tag = "v${version}";
    hash = "sha256-OmCtyUCShNQez+tHpOHervAUoIbbIgePqR6nx/vRnoU=";
  };

  # Step 1: Fixed-output derivation for dependencies
  deps = stdenv.mkDerivation {
    pname = "${pname}-deps";
    inherit version src;

    nativeBuildInputs = [bun];

    dontBuild = true;
    dontFixup = true;

    installPhase = ''
      export HOME=$TMPDIR

      # Install dependencies
      bun install --frozen-lockfile --no-cache

      # Copy to output
      mkdir -p $out
      cp -r node_modules $out/
      cp pnpm-lock.yaml package.json $out/
    '';

    # This hash represents the dependencies
    outputHash = "sha256-qmvKQJu+pLHbKzIz4Z3nqZNquvrAVIkauy/EkeDFpSw=";
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
  };
  # Step 2: Main build derivation
in
  stdenv.mkDerivation {
    inherit
      pname
      version
      src
      ;

    nativeBuildInputs = [
      bun
      makeWrapper
      nodejs-slim
    ];

    buildPhase = ''
      runHook preBuild

      export HOME=$TMPDIR

      cp -r ${deps}/node_modules .
      cp ${deps}/pnpm-lock.yaml .

      substituteInPlace node_modules/.bin/run-s \
        --replace-fail "/usr/bin/env node" "${getExe nodejs-slim}"
      substituteInPlace node_modules/.bin/tsx \
        --replace-fail "/usr/bin/env node" "${getExe nodejs-slim}"

      bun run build

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/lib/${pname}

      cp -r dist $out/lib/${pname}/

      cp -r node_modules $out/lib/${pname}/
      cp package.json $out/lib/${pname}/

      chmod +x $out/lib/${pname}/dist/index.js

      mkdir -p $out/bin
      makeWrapper $out/lib/${pname}/dist/index.js $out/bin/${pname} \
        --prefix PATH : ${makeBinPath [nodejs-slim]} \

      runHook postInstall
    '';

    meta = with lib; {
      description = "A Model Context Protocol (MCP) proxy server that enables efficient management of large tool collections.";
      homepage = "https://github.com/d-kimuson/modular-mcp";
      license = licenses.mit;
      mainProgram = "${pname}";
    };
  }
