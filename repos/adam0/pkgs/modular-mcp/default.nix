{
  # keep-sorted start
  bun,
  fetchFromGitHub,
  lib,
  makeWrapper,
  nodejs-slim,
  stdenv,
  # keep-sorted end
}: let
  inherit
    (lib)
    # keep-sorted start
    getExe
    makeBinPath
    # keep-sorted end
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
      # keep-sorted start
      pname
      src
      version
      # keep-sorted end
      ;

    nativeBuildInputs = [
      # keep-sorted start
      bun
      makeWrapper
      nodejs-slim
      # keep-sorted end
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
      # keep-sorted start
      description = "A Model Context Protocol (MCP) proxy server that enables efficient management of large tool collections";
      homepage = "https://github.com/d-kimuson/modular-mcp";
      license = licenses.mit;
      mainProgram = pname;
      platforms = platforms.unix;
      # keep-sorted end
    };
  }
