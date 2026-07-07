{
  buildPackages,
  fetchFromGitHub,
  installShellFiles,
  lib,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  stdenv,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "kagi-cli";
  version = "0.14.2";

  src = fetchFromGitHub {
    owner = "Microck";
    repo = "kagi-cli";
    rev = "v${finalAttrs.version}";
    hash = "sha256-tTEGzqiV5YfFOIiD4Dy+aRK3eC6BmiMMUrNDYofLIrc=";
  };

  cargoHash = "sha256-j8EQx019SGFmLvKskv52XOwPP4jIPPU1J5gVzlEjra8=";

  nativeBuildInputs = [
    pkg-config
    installShellFiles
  ];

  buildInputs = [
    openssl
  ];

  checkFlags = [
    "--skip=mcp_tool_call_error_returns_json_rpc_error_and_keeps_server_alive"
  ];

  postInstall = let
    emulator = stdenv.hostPlatform.emulator buildPackages;
  in lib.optionalString (stdenv.hostPlatform.emulatorAvailable buildPackages) ''
    installShellCompletion --cmd kagi \
      --bash <(${emulator} $out/bin/kagi completion generate bash) \
      --fish <(${emulator} $out/bin/kagi completion generate fish) \
      --zsh <(${emulator} $out/bin/kagi completion generate zsh)
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    changelog = "https://github.com/Microck/kagi-cli/releases/tag/v${finalAttrs.version}";
    description = "terminal CLI for Kagi that gives you command-line access to search, lenses, assistant, summarization, feeds, and paid API commands";
    homepage = "https://kagi.micr.dev";
    license = lib.licenses.mit;
    mainProgram = "kagi";
    maintainers = with lib.maintainers; [ colinsane ];
  };
})
