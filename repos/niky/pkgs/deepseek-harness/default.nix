{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  pnpmConfigHook,
  pnpmBuildHook,
  makeBinaryWrapper,
  pnpm,
  python3,
  nodejs_26,
  bubblewrap,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "deepseek-harness";
  version = "0.1.0-rc.5";

  src = fetchFromGitHub {
    owner = "deepseek-ai";
    repo = "deepseek-harness";
    rev = "abe560f81edebe5f6a5b62706ff502daa0dccd40";
    sha256 = "sha256-ZPGCNoPXVjP76Tm/tFPDX2X95cd83M4iHLmVP5dR+Ps=";
  };

  __structuredAttrs = true;
  strictDeps = true;

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 4;
    hash = "sha256-aySHq0ywTMM5q7YuGHZrV3yQE3bwppgGfWH3wRnHCXk=";
  };

  nativeBuildInputs = [
    pnpm
    nodejs_26
    pnpmConfigHook
    pnpmBuildHook
    makeBinaryWrapper
    python3
  ];

  buildInputs = [
    nodejs_26
    bubblewrap
  ];

  pnpmBuildScript = "build";

  postBuild = ''
    for dir in ''$(find node_modules -type d -name "node-pty"); do
      cd ''$dir
      npm_config_nodedir="${nodejs_26}"  ${nodejs_26}/bin/npm run install
      cd ''$OLDPWD
    done
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    cp -r node_modules packages python vendor website native apps "$out/"
    rm -f $out/node_modules/.pnpm/node_modules/dsh-examples
    rm -f $out/node_modules/.pnpm/node_modules/dsh-jsonrpc-agent-pkg

    runHook postInstall
  '';

  postInstall = ''
    mkdir -p "$out/bin"
    makeBinaryWrapper ${nodejs_26}/bin/node "$out/bin/dsh" \
        --prefix PATH : ${lib.makeBinPath [ bubblewrap ]} \
        --add-flags "--expose-internals $out/apps/cli/lib/bin.js"
  ''; #              ^~~~~~~~~~~~~~~~~~ The optional native module is not compatible with Nixpkgs Node.js

  meta = {
    mainProgram = "dsh";
    homepage = "https://github.com/deepseek-ai/deepseek-harness/";
    description = "An open-source agent harness developed by DeepSeek AI.";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
