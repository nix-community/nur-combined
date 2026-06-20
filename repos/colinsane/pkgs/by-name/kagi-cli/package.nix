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
  version = "0.11.0";

  src = fetchFromGitHub {
    owner = "Microck";
    repo = "kagi-cli";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Quuvn+AyTaQc14sJtExr4hDv6t+HpSat+88H5CSkuAM=";
  };

  cargoHash = "sha256-E8/4He2WXt4Nxd1wzGhU2iwIu6xlfOxlHHbxlpI0Jtg=";

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
