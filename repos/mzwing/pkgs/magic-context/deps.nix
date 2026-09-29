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
    # --filter alone switches bun to the isolated linker, which puts the real packages under node_modules/.bun and leaves symlink farms per workspace.
    # --backend hardlink matches Linux: under macOS's clonefile, a bin chmod on one copy of a package misses its other copies.
    bun install \
      --frozen-lockfile \
      --ignore-scripts \
      --no-progress \
      --linker hoisted \
      --backend hardlink \
      --filter ./packages/cli \
      --filter ./packages/plugin \
      --filter ./packages/pi-plugin \
      --filter ./packages/retina-local-fs

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    # Some dependencies cannot hoist and stay in their own workspace, so mirror the tree rather than copying one directory.
    mapfile -t trees < <(find . -maxdepth 3 -type d -name node_modules -prune)
    bun ${./prune-platform-packages.mjs} "''${trees[@]}"

    mkdir -p $out
    for tree in "''${trees[@]}"; do
      mkdir -p "$out/$(dirname "$tree")"
      cp -R "$tree" "$out/$tree"
    done

    runHook postInstall
  '';

  env.SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";

  outputHashAlgo = "sha256";
  outputHashMode = "recursive";
  outputHash = bunDepsHash;
}
