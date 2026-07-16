{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "agent-lsp";
  version = "0.16.0";

  src = fetchFromGitHub {
    owner = "blackwell-systems";
    repo = "agent-lsp";
    rev = "v${finalAttrs.version}";
    hash = "sha256-0SNpLduoHKydIuZpd8C7S9tR1HK9YuZSh+Af6V6HBBo=";
  };

  vendorHash = "sha256-7xbpuIN0dlI1IKSlTVKnrtbUpCzdZmno6kgi7xUqGFA=";
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
