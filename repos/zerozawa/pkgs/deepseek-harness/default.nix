{
  lib,
  buildNpmPackage,
  nodejs,
  python3,
  pkg-config,
  stdenv,
  makeWrapper,
}:

buildNpmPackage rec {
  pname = "deepseek-harness";
  version = "0.1.1-rc.2";

  # Stub project depending on the npm-published @deepseek-ai/dsh bundle; the
  # source repo is a pnpm monorepo whose published package ships the same
  # prebuilt lib/ the README's `npx @deepseek-ai/dsh web` path runs.
  src = ./.;

  npmDepsHash = "sha256-wVB8Cxpvnnz1g/Hx9gjzmksKrK5BA2Zz5V6LkW+HNQ4=";

  # node-pty ships no linux prebuild, so npm ci falls back to `node-gyp
  # rebuild`; point it at the offline header tree.
  nativeBuildInputs = [
    makeWrapper
    python3
    pkg-config
  ];
  buildInputs = [ stdenv.cc.cc.lib ];

  env.npm_config_nodedir = "${nodejs}";

  dontNpmBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib
    cp -r node_modules $out/lib/

    # node-addon-require-builtin's V8-layout probe only recognizes official
    # nodejs.org builds and fails on Nix source-built Node (verified locally
    # with 0.1.5; deepseek-ai/deepseek-harness discussions #690, #752, #1873).
    # `--expose-internals` is the upstream-validated workaround and Node
    # rejects it in NODE_OPTIONS, so it must go on argv.
    makeWrapper ${lib.getExe nodejs} $out/bin/dsh \
      --add-flags "--expose-internals $out/lib/node_modules/@deepseek-ai/dsh/lib/bin.js"

    runHook postInstall
  '';

  meta = with lib; {
    description = "DeepSeek Harness (`dsh`) is an open-source agent harness developed by DeepSeek AI.";
    # official product page; the GitHub repo is the source/download page
    homepage = "https://www.deepseek.com/harness/";
    downloadPage = "https://github.com/deepseek-ai/deepseek-harness";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "dsh";
    sourceProvenance = with sourceTypes; [
      binaryBytecode
      binaryNativeCode
    ];
  };
}
