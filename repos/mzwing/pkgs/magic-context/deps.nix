# bun install tree, pruned to hash identically on every system.
{
  stdenvNoCC,
  bun,
  cacert,
  source,
  version,
  bunDepsHash,
}:
stdenvNoCC.mkDerivation {
  pname = "magic-context-node-modules";
  inherit (source) src;
  inherit version;

  nativeBuildInputs = [bun];

  dontConfigure = true;
  dontFixup = true;

  buildPhase = ''
    runHook preBuild

    export HOME=$TMPDIR

    # dashboard, docs and e2e-tests drag in Tauri, Astro and Cloudflare for nothing.
    # --ignore-scripts also skips onnxruntime-node's CUDA download.
    bun install \
      --frozen-lockfile \
      --ignore-scripts \
      --no-progress \
      --filter ./packages/cli \
      --filter ./packages/plugin \
      --filter ./packages/pi-plugin \
      --filter ./packages/retina-local-fs

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    bun ${./prune-platform-packages.mjs} node_modules

    # Workspace links are relative, so the tree survives being copied into a fresh checkout.
    cp -R node_modules $out

    runHook postInstall
  '';

  env.SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";

  outputHashAlgo = "sha256";
  outputHashMode = "recursive";
  outputHash = bunDepsHash;
}
