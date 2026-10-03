{
  lib,
  autoAddDriverRunpath,
  cmake,
  cudaPackages ? { },
  cudaSupport ? false,
  fetchFromGitHub,
  fetchNpmDeps,
  installShellFiles,
  ninja,
  nodejs_latest,
  npmHooks,
  nix-update-script,
  openssl,
  stdenv,
}:

let
  version = "b10754-2459f68";
  hash = "sha256-3tASDsQU5JcTb2TIGEXaLpTK4T6osikndyVVBCWa8R4=";

  buildInfo = lib.match "b([0-9]+)-([0-9a-f]+)" version;
  buildNumber = if buildInfo != null then builtins.elemAt buildInfo 0 else "0";
  buildCommit = if buildInfo != null then builtins.elemAt buildInfo 1 else "unknown";

  effectiveStdenv = if cudaSupport then cudaPackages.backendStdenv else stdenv;
in
effectiveStdenv.mkDerivation (finalAttrs: {
  pname = "prismml-llama-cpp";

  npmRoot = "tools/ui";

  __structuredAttrs = true;
  strictDeps = true;

  inherit version hash;
  patches = [ ];
  src = fetchFromGitHub {
    owner = "PrismML-Eng";
    repo = "llama.cpp";
    tag = "prism-${finalAttrs.version}";
    inherit hash;
  };

  nativeBuildInputs = [
    cmake
    installShellFiles
    ninja
    nodejs_latest
    npmHooks.npmConfigHook
  ]
  ++ lib.optionals cudaSupport [
    cudaPackages.cuda_nvcc
    autoAddDriverRunpath
  ];

  buildInputs = [
    openssl
  ]
  ++ lib.optionals cudaSupport (
    with cudaPackages;
    [
      cccl
      cuda_cudart
      libcublas
    ]
  );

  npmDepsHash = "sha256-2Q7XhaLAArmviOLdQsNbYTfdyDE5pW9lR26cRHEVl9k=";
  npmDeps = fetchNpmDeps {
    name = "${finalAttrs.pname}-${finalAttrs.version}-npm-deps";
    inherit (finalAttrs) src patches;
    preBuild = ''
      pushd ${finalAttrs.npmRoot}
    '';
    hash = finalAttrs.npmDepsHash;
  };

  preConfigure = ''
    pushd ${finalAttrs.npmRoot}
    LLAMA_BUILD_NUMBER=${buildNumber} npm run build
    popd
  '';

  doCheck = false;

  cmakeFlags = [
    (lib.cmakeBool "GGML_NATIVE" false)
    (lib.cmakeBool "GGML_CPU_ALL_VARIANTS" true)
    (lib.cmakeBool "GGML_BACKEND_DL" true)
    (lib.cmakeBool "LLAMA_BUILD_IS_DEV" false)
    (lib.cmakeBool "LLAMA_BUILD_TESTS" false)
    (lib.cmakeBool "LLAMA_BUILD_SERVER" true)
    (lib.cmakeBool "LLAMA_OPENSSL" true)
    (lib.cmakeBool "BUILD_SHARED_LIBS" true)
    (lib.cmakeBool "GGML_CUDA" cudaSupport)
    (lib.cmakeFeature "LLAMA_BUILD_NUMBER" buildNumber)
    (lib.cmakeFeature "LLAMA_BUILD_COMMIT" buildCommit)
  ]
  ++ lib.optionals cudaSupport [
    (lib.cmakeFeature "CMAKE_CUDA_ARCHITECTURES" cudaPackages.flags.cmakeCudaArchitecturesString)
  ];

  postInstall = ''
    installShellCompletion --cmd llama-server --bash <($out/bin/llama-server --completion-bash)
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "^prism-(.*)$"
    ];
  };

  meta = {
    description = "PrismML fork of llama.cpp with runtime CPU dispatch and unified llama binary";
    homepage = "https://github.com/PrismML-Eng/llama.cpp";
    license = lib.licenses.mit;
    mainProgram = "llama";
    maintainers = with lib.maintainers; [ xddxdd ];
    platforms = lib.platforms.unix;
  }
  // lib.optionalAttrs cudaSupport {
    badPlatforms = lib.platforms.darwin;
  };
})
