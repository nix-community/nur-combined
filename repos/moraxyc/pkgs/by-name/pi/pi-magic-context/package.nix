{
  lib,
  buildNpmPackage,
  importNpmLock,
  nodejs,
  onnxruntime-node,
  piBundleHook,

  sources,
  source ? sources.magic-context,
}:

let
  # Bun gives bundled CommonJS modules a `require`; esbuild needs it injected.
  requireBanner = ''--banner:js=import { createRequire as __createRequire } from "node:module"; const require = __createRequire(import.meta.url);'';
  memory = "../plugin/src/features/magic-context/memory";
in
buildNpmPackage (finalAttrs: {
  pname = "pi-magic-context";
  inherit (source) version src;
  __structuredAttrs = true;
  strictDeps = true;

  patches = [
    source.artifacts."npm-workspace.patch"
    # Uses CUDA for native embeddings when the linked onnxruntime has it.
    ./native-cuda-device.patch
  ];

  npmDeps = importNpmLock source.npmDeps;
  npmConfigHook = importNpmLock.npmConfigHook;
  npmFlags = [ "--ignore-scripts" ];

  # Pi loads this extension directly; keep Node out of the runtime closure.
  dontPatchShebangs = true;

  nativeBuildInputs = [ piBundleHook ];

  # Transformers.js loads onnxruntime-node through createRequire, which the shim
  # alias cannot see, so upstream's WASM fallback would still load the native addon.
  preBuild = ''
    substituteInPlace node_modules/@huggingface/transformers/src/backends/onnx-node.js \
      --replace-fail "export default requireFromHere('onnxruntime-node');" \
                     "export { default } from 'onnxruntime-node';"
  '';

  # Replaces upstream's `bun build` of the Transformers.js WASM fallbacks. The Node
  # one aliases the native addons to upstream's WASM shims, as build-transformers-node-wasm.ts does.
  buildPhase = ''
    runHook preBuild

    pushd packages/pi-plugin
    esbuild ${memory}/transformers-web-entry.ts \
      --bundle --platform=browser --format=esm \
      --external:onnxruntime-web \
      --outfile=dist/transformers-web.js
    esbuild ${memory}/transformers-node-wasm-entry.ts \
      --bundle --platform=node --format=esm \
      --external:onnxruntime-web '--external:onnxruntime-web/*' \
      --alias:@huggingface/transformers=../../node_modules/@huggingface/transformers/src/transformers.js \
      --alias:@magic-context/transformers-node-hub=../../node_modules/@huggingface/transformers/src/utils/hub.js \
      --alias:onnxruntime-node=${memory}/onnxruntime-node-wasm-shim.ts \
      --alias:sharp=${memory}/sharp-wasm-shim.ts \
      '${requireBanner}' \
      --outfile=dist/transformers-node-wasm.js
    popd

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/${finalAttrs.pname}/node_modules
    cp -r packages/pi-plugin/{package.json,dist} $out/lib/${finalAttrs.pname}/
    # Both runtimes are resolved next to the bundle: native from the Nixpkgs
    # onnxruntime, and WASM as the fallback and for `local_runtime: "wasm"`.
    ln -s ${onnxruntime-node}/lib/node_modules/onnxruntime-node $out/lib/${finalAttrs.pname}/node_modules/
    cp -r node_modules/onnxruntime-web $out/lib/${finalAttrs.pname}/node_modules/
    # Node uses the CPU WASM backend only; drop source maps, sources, and the
    # browser and GPU/JSPI variants (about 120M of the 125M dist).
    pushd $out/lib/${finalAttrs.pname}/node_modules/onnxruntime-web
    rm dist/*.map
    rm -r lib docs dist/*{jsep,asyncify,jspi}* dist/ort.{all,webgl}*
    popd

    runHook postInstall
  '';

  # Entries and externals follow upstream's pi-plugin `build` script. Workers are
  # spawned by file name from dist, so they need splitting with stable names.
  piBundleSrcDir = "packages/pi-plugin";
  piBundleSplitting = true;
  # OMP rewrites external typebox imports to a shim that breaks tool registration.
  piBundleInlineTypebox = true;
  piBundleKeepNodeModules = true;
  piBundleEntries = [
    "src/index.ts"
    "src/tag-snapshot-worker-pi.ts"
    "src/subagent-entry.ts"
    "src/historian-calibration-extension.ts"
    "${memory}/embedding-worker.ts"
    "${memory}/embedding-worker-process.ts"
    "../plugin/src/features/magic-context/migration-worker.ts"
    "../plugin/src/hooks/magic-context/auto-search-worker.ts"
    "../plugin/src/hooks/magic-context/raw-ordinal-warmup-worker.ts"
    "../plugin/src/features/magic-context/compaction-marker-candidates-worker.ts"
    "../plugin/src/features/magic-context/chunk-embedding-write-worker.ts"
  ];
  piBundleEsbuildFlags = [
    "--external:@oh-my-pi/*"
    "--external:onnxruntime-node"
    "--external:onnxruntime-web"
    # Only Transformers.js imports sharp, for image inputs that text embeddings never use.
    "--alias:sharp=./packages/plugin/src/features/magic-context/memory/sharp-wasm-shim.ts"
    "--external:bun:ffi"
    "--external:node:sqlite"
    requireBanner
  ];

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    pushd $out/lib/${finalAttrs.pname}
    for f in index transformers-node-wasm; do
      node --input-type=module -e "await import('./dist/$f.js')"
    done
    node --input-type=module -e "await import('onnxruntime-node')"
    node --input-type=module < ${./check-onnxruntime-web.mjs}
    popd

    runHook postInstallCheck
  '';

  disallowedReferences = [ nodejs ];

  meta = {
    description = "Magic Context extension for the Pi coding agent: cross-session memory and context management";
    homepage = "https://github.com/cortexkit/magic-context";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
  };
})
