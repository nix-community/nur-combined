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

rustPlatform.buildRustPackage {
  pname = "lsp-ai";
  version = "0-unstable-2026-01-01";

  src = fetchFromGitHub {
    owner = "XYenon";
    repo = "lsp-ai";
    rev = "6f490d2feb616597a28c5a3682e97dfed47d4f67";
    hash = "sha256-ITqsF7I7T8zzybSkaXiXW2sFLHtB8IVEDiTuI481F1g=";
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

  cargoHash = "sha256-5yI3S/o/VrsYWFrdWCcJlNUWOtPLPTESRv8T8nS6PeI=";

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
