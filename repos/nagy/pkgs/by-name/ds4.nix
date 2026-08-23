{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation {
  pname = "ds4";
  version = "0-unstable-2026-08-09";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "antirez";
    repo = "ds4";
    rev = "84cc882352757baf628a1776badf7cc54d584e28";
    hash = "sha256-mdvKxI+/vDQcrpHepvXPmYcTjPTRnqJWWU0UFFnLJJk=";
  };

  enableParallelBuilding = true;

  # For a native build nixpkgs offers stdenv.adapters.impureUseNativeOptimizations.
  makeFlags = [ "cpu" ];

  doCheck = true;

  checkPhase = ''
    runHook preCheck
    make q4k-dot-test mxfp4-dot-test tests/test_layer_pack tests/test_gpu_args
    ./tests/test_layer_pack
    ./tests/test_gpu_args
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
}
