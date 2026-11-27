{
  lib,
  stdenv,
  cmake,
  esbuild,
  nodejs,
  onnxruntime,

  sources,
}:

let
  inherit (stdenv.hostPlatform) node;
  bindingDir = "bin/napi-v6/${node.platform}/${node.arch}";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "onnxruntime-node";
  inherit (onnxruntime) version;
  __structuredAttrs = true;
  strictDeps = true;

  srcs = [
    onnxruntime.src
    sources.node-addon-api.src
  ];
  sourceRoot = onnxruntime.src.name;

  # The binding's CMakeLists includes node-addon-api from js/node/node_modules.
  postUnpack = ''
    mkdir -p $sourceRoot/js/node/node_modules
    mv package $sourceRoot/js/node/node_modules/node-addon-api
  '';

  nativeBuildInputs = [
    cmake
    esbuild
    nodejs
  ];
  buildInputs = [ onnxruntime ];

  # Built without cmake-js, which would download Node headers.
  cmakeDir = "../js/node";
  cmakeFlags = [
    (lib.cmakeFeature "CMAKE_JS_INC" "${nodejs}/include/node")
    (lib.cmakeFeature "NODE_ARCH" node.arch)
    (lib.cmakeFeature "napi_build_version" "6")
    (lib.cmakeFeature "ONNXRUNTIME_BUILD_DIR" "${lib.getLib onnxruntime}/lib")
    (lib.cmakeBool "USE_CUDA" onnxruntime.cudaSupport)
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    (lib.cmakeFeature "CMAKE_SHARED_LINKER_FLAGS" "-undefined dynamic_lookup")
  ];

  # Transpiled per file, not bundled: esbuild cannot leave the binding's computed require alone.
  postBuild = ''
    esbuild ../js/node/lib/*.ts --platform=node --format=cjs --outdir=dist/node
    esbuild ../js/common/lib/*.ts --platform=node --format=cjs --outdir=dist/common
  '';

  installPhase = ''
    runHook preInstall

    pkg=$out/lib/node_modules/onnxruntime-node
    common=$pkg/node_modules/onnxruntime-common
    mkdir -p $pkg $common
    cp -r dist/node $pkg/dist
    cp -r dist/common $common/dist
    install -Dm755 -t $pkg/${bindingDir} ../js/node/${bindingDir}/onnxruntime_binding.node
    # The binding finds the runtime next to itself ($ORIGIN / @loader_path).
    for lib in ../js/node/${bindingDir}/libonnxruntime*; do
      ln -s ${lib.getLib onnxruntime}/lib/$(basename $lib) $pkg/${bindingDir}/
    done
    echo '{"name": "onnxruntime-node", "version": "${finalAttrs.version}", "main": "dist/index.js"}' > $pkg/package.json
    echo '{"name": "onnxruntime-common", "version": "${finalAttrs.version}", "main": "dist/index.js"}' > $common/package.json

    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    pushd $out/lib/node_modules
    node ${./check.cjs}
    popd

    runHook postInstallCheck
  '';

  disallowedReferences = [ nodejs ];

  meta = {
    description = "ONNX Runtime Node.js binding linked against the Nixpkgs onnxruntime";
    homepage = "https://github.com/microsoft/onnxruntime/tree/main/js/node";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
