{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "agent-lsp";
  version = "0.15.0";

  src = fetchFromGitHub {
    owner = "blackwell-systems";
    repo = "agent-lsp";
    rev = "v${finalAttrs.version}";
    hash = "sha256-l04uuMP4giVUykDpR4mWK2P+Tkj/E16EqDuMOEYNa8U=";
  };

  vendorHash = "sha256-rp0PiqdZXZoHKoCuHPk/dEnt8xO2PcmQIXFTugEoqP4=";
  proxyVendor = true;

  subPackages = [
    "cmd/agent-lsp"
  ];

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${finalAttrs.version}"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "MCP server that orchestrates language servers for AI agents";
    longDescription = ''
      agent-lsp is a Model Context Protocol (MCP) server that orchestrates
      existing LSP servers (gopls, rust-analyzer, pyright, nixd, etc.) into
      agent-native workflows. It exposes code intelligence, navigation,
      refactoring, and speculative editing tools to AI agents.
    '';
    mainProgram = "agent-lsp";
    homepage = "https://github.com/blackwell-systems/agent-lsp";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ colinsane ];
  };
})
