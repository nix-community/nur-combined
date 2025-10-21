{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  cmake,
  openssl,
  zlib,
  perl,
  nix-update-script,
}:

rustPlatform.buildRustPackage rec {
  pname = "lsp-ai";
  version = "0-unstable-2025-10-21";

  src = fetchFromGitHub {
    owner = "XYenon";
    repo = "lsp-ai";
    rev = "b3605460ecb82d9066b72d0cf916a739b6a7ce75";
    hash = "sha256-i1UC8xF58stQun85glZKW9sYCV8o4xpQbGYgxLmDetI=";
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

  cargoHash = "sha256-1xGzkHgs/4wzTVnlAl/uw1Z1nQ5nuz7TE87I3Qsh4kQ=";

  nativeBuildInputs = [
    pkg-config
    cmake
    perl
  ];

  buildInputs = [
    openssl
    zlib
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Open-source language server that serves as a backend for AI-powered functionality";
    homepage = "https://github.com/XYenon/lsp-ai";
    mainProgram = "lsp-ai";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ xyenon ];
  };
}
