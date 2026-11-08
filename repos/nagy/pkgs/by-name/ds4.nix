{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ds4";
  version = "0-unstable-2026-11-03";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "antirez";
    repo = "ds4";
    rev = "b3f50180ec2c7324892be1f50bc83555ccb8d5e7";
    hash = "sha256-XccxnYqo33w1mNZNAMFx/rdPhO57lxQ/oKPGSyxzh0E=";
  };

  enableParallelBuilding = true;

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  # For a native build nixpkgs offers stdenv.adapters.impureUseNativeOptimizations.
  makeFlags = [ "cpu" ];

  doCheck = true;

  checkPhase = ''
    runHook preCheck
    make q4k-dot-test mxfp4-dot-test \
      tests/test_layer_pack tests/test_gpu_args tests/test_prompt_prefix
    ./tests/test_layer_pack
    ./tests/test_gpu_args
    ./tests/test_prompt_prefix
    ./ds4-eval --self-test-extractors
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 -t $out/bin ds4 ds4-server ds4-bench ds4-eval ds4-agent
    runHook postInstall
  '';

  meta = {
    description = "Native inference engine for DeepSeek V4 Flash, GLM 5.2, and DeepSeek V4 PRO";
    homepage = "https://github.com/antirez/ds4";
    license = lib.licenses.mit;
    mainProgram = "ds4";
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ nagy ];
  };
})
