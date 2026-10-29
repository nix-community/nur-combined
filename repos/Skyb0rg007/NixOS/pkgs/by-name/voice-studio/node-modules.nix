# electron/bun.lock is stale; install from the root workspace lockfile. All
# OS/CPU variants are fetched so the hash is platform-independent.
{
  lib,
  stdenvNoCC,
  bun,
  writableTmpDirAsHomeHook,
  voice-studio,
}:
stdenvNoCC.mkDerivation {
  pname = "${voice-studio.pname}-node-modules";
  inherit (voice-studio) version src;
  __structuredAttrs = true;
  strictDeps = true;

  impureEnvVars = lib.fetchers.proxyImpureEnvVars ++ [
    "GIT_PROXY_COMMAND"
    "SOCKS_SERVER"
  ];

  nativeBuildInputs = [
    bun
    writableTmpDirAsHomeHook
  ];

  dontConfigure = true;
  dontFixup = true;

  buildPhase = ''
    runHook preBuild

    export BUN_INSTALL_CACHE_DIR=$(mktemp -d)
    export ELECTRON_SKIP_BINARY_DOWNLOAD=1

    bun install \
      --filter=./electron \
      --force \
      --frozen-lockfile \
      --cpu="*" \
      --os="*" \
      --ignore-scripts \
      --linker=hoisted \
      --no-progress

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -R ./node_modules $out/node_modules
    for ws in electron; do
      if [ -d $ws/node_modules ]; then
        mkdir -p $out/$ws
        cp -R $ws/node_modules $out/$ws/node_modules
      fi
    done

    runHook postInstall
  '';

  outputHash = "sha256-BAZgZuU+EwZovXu3hP/A9/WePC3/AyTUEZxlvqvQL4E=";
  outputHashAlgo = "sha256";
  outputHashMode = "recursive";
}
