{
  stdenv,
  lib,
  nodejs,
  pnpm,
  makeWrapper,
  source,
}:

stdenv.mkDerivation rec {
  inherit (source) pname src;
  version = "0-unstable-" + source.date;

  nativeBuildInputs = [
    nodejs
    pnpm.configHook
    makeWrapper
  ];

  pnpmDeps = pnpm.fetchDeps {
    inherit pname version src;
    hash = "sha256-R3ToLxFcNS7nZgF4zJ5K9UPKtToTr3GIj3L9e/wwDAo=";
    fetcherVersion = 2;
  };

  buildPhase = ''
    runHook preBuild

    pnpm build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/opt

    # Copy built files
    cp -r . $out/opt/$pname
    # cp package.json $out/lib/node_modules/@musistudio/claude-code-router/
    makeWrapper ${lib.getExe nodejs} $out/bin/ccr \
      --add-flags $out/opt/$pname/dist/cli.js

    runHook postInstall
  '';

  meta = {
    description = "Use Claude Code without an Anthropics account and route it to another LLM provider";
    homepage = "https://github.com/musistudio/claude-code-router";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.wrvsrx ];
    platforms = lib.platforms.all;
    mainProgram = "ccr";
  };
}
