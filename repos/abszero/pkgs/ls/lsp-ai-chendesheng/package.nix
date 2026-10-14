{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  cmake,
  oniguruma,
  openssl,
  zlib,
  perl,
  gitUpdater,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "lsp-ai-chendesheng";
  version = "0-unstable-2026-10-04";
  src = fetchFromGitHub {
    owner = "chendesheng";
    repo = "lsp-ai";
    rev = "af5eda03bfec9a7dc06d57b04b87256d1e901105";
    hash = "sha256-kxj2rmd3eEWiGnWjeOYZVtIMkOdJZdHxFMoxUOj7nCU=";
  };

  checkFlags = [
    # These integ tests require an account and network usage to work
    "--skip=transformer_backends::open_ai::test::open_ai_completion_do_generate"
    "--skip=transformer_backends::mistral_fim::test::mistral_fim_do_generate"
    "--skip=transformer_backends::anthropic::test::anthropic_chat_do_generate"
    "--skip=transformer_backends::open_ai::test::open_ai_chat_do_generate"
    "--skip=transformer_backends::gemini::test::gemini_chat_do_generate"
    "--skip=transformer_backends::ollama::test::ollama_chat_do_generate"
    "--skip=transformer_backends::ollama::test::ollama_completion_do_generate"
    "--skip=embedding_models::ollama::test::ollama_embeding"
    "--skip=transformer_worker::tests::test_do_completion"
    "--skip=transformer_worker::tests::test_do_generate"
    "--skip=memory_backends::vector_store::tests::can_open_document"
    "--skip=memory_backends::vector_store::tests::can_rename_document"
    "--skip=memory_backends::vector_store::tests::can_build_prompt"
    "--skip=memory_backends::vector_store::tests::can_change_document"
    # These integ test require a LLM server to be running over the network
    "--skip=lsp_ai::transformer_worker"
    "--skip=lsp_ai::memory_worker"
    "--skip=test_chat_sequence"
    "--skip=test_completion_action_sequence"
    "--skip=test_chat_completion_sequence"
    "--skip=test_completion_sequence"
    "--skip=test_fim_completion_sequence"
    "--skip=test_refactor_action_sequence"
  ];

  cargoHash = "sha256-Zm/ibNWCTIXJbTqpiH+yVTAVJgzuy+lx8MKnc5rB28Y=";

  nativeBuildInputs = [
    pkg-config
    cmake
    perl
  ];

  buildInputs = [
    oniguruma
    openssl
    zlib
  ];

  # use system oniguruma since the bundled one fails to build with gcc15
  env.RUSTONIG_SYSTEM_LIBONIG = 1;

  cargoBuildFlags = [ "-p lsp-ai" ];

  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
  };

  meta = {
    description = "Open-source language server that serves as a backend for AI-powered functionality (chendesheng's fork)";
    homepage = "https://github.com/chendesheng/lsp-ai";
    mainProgram = "lsp-ai";
    changelog = "https://github.com/chendesheng/lsp-ai/releases/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ weathercold ];
  };
})
