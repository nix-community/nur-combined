{
  lib,
  buildGoModule,
  fetchFromGitHub,
  versionCheckHook,
  nix-update-script,
}:

buildGoModule rec {
  pname = "github-mcp-server";
  version = "1.9.0";

  src = fetchFromGitHub {
    owner = "github";
    repo = "github-mcp-server";
    tag = "v${version}";
    hash = "sha256-zG6WwhY7j08Qqvj+BCpBIU6UaS4Di5aksjlnCgZ0Z2c=";
  };

  vendorHash = "sha256-QztH+35KQReYsft50WBZMB0EEBWmQZiSA/mFzsvLSQU=";

  ldflags = [
    "-s"
    "-w"
    "-X=main.version=${version}"
    "-X=main.commit=v${version}"
    "-X=main.date=1970-01-01T00:00:00Z"
  ];

  __darwinAllowLocalNetworking = true;

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "GitHub's official MCP Server";
    longDescription = ''
      Model Context Protocol server for GitHub. Lets AI assistants (e.g.
      Claude, Gemini, GPT-5, Copilot) query and manipulate GitHub repositories
      directly - issues, PRs, code, actions and more.
    '';
    homepage = "https://github.com/github/github-mcp-server";
    changelog = "https://github.com/github/github-mcp-server/releases/tag/v${version}";
    license = licenses.mit;
    maintainers = with maintainers; [ ataraxiasjel ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    mainProgram = "github-mcp-server";
  };
}
