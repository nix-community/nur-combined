{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "edge0";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "Edge0-AI";
    repo = "Edge0";
    tag = "v${finalAttrs.version}";
    hash = "sha256-4yoIXRTedL8JaV12sqY7jfiLb02QP3nUxL67djnp0lw=";
  };

  sourceRoot = "${finalAttrs.src.name}/edge0-infer";

  nativeBuildInputs = [
    cmake
    ninja
  ];

  cmakeFlags = [
    # Match the upstream `cpu` / `mac-metal` presets (CMakePresets.json).
    (lib.cmakeBool "BUILD_SHARED_LIBS" false)
    (lib.cmakeBool "GGML_BUILD_TESTS" false)
    (lib.cmakeBool "GGML_BUILD_EXAMPLES" false)
    (lib.cmakeBool "GGML_BACKEND_DL" false)
    (lib.cmakeBool "GGML_CPU" true)
    (lib.cmakeBool "GGML_OPENMP" false)
    (lib.cmakeBool "GGML_BLAS" false)
    (lib.cmakeBool "GGML_ACCELERATE" false)
    (lib.cmakeBool "GGML_LLAMAFILE" false)
    # Avoid -march=native so the build is reproducible across machines.
    (lib.cmakeBool "GGML_NATIVE" false)
    (lib.cmakeBool "MOE_BUILD_TESTS" false)
    (lib.cmakeBool "MOE_BUILD_EXAMPLES" false)
    (lib.cmakeBool "GGML_METAL" stdenv.hostPlatform.isDarwin)
    (lib.cmakeBool "GGML_METAL_EMBED_LIBRARY" stdenv.hostPlatform.isDarwin)
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    (lib.cmakeFeature "CMAKE_C_FLAGS" "-D__ARM_FEATURE_DOTPROD=1")
  ];

  # Upstream only installs ggml targets; the CLI has no install() rule.
  installPhase = ''
    runHook preInstall
    install -Dm755 bin/edge0-infer "$out/bin/edge0-infer"
    runHook postInstall
  '';

  # versionCheckHook cannot be used: the 0.3.0 tag still reports
  # `engine.version: 0.2.0` and the CLI has no --version flag. Only check that
  # the binary runs.
  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    "$out/bin/edge0-infer" info > /dev/null
    runHook postInstallCheck
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Streaming MoE inference engine (CLI, local OpenAI/Anthropic server)";
    longDescription = ''
      edge0-infer is the unified Edge0 inference CLI and local server. On Linux
      and Darwin it builds the native GGML engine used for Edge0 35B (CPU; Metal
      on Darwin). Edge0 145B/120B need the separate edge0-strata CUDA engine from
      the same repository and are not included here.
    '';
    homepage = "https://github.com/Edge0-AI/Edge0";
    changelog = "https://github.com/Edge0-AI/Edge0/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "edge0-infer";
    platforms = lib.platforms.unix;
  };
})
