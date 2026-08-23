{
  lib,
  buildGoModule,
  fetchFromGitHub,
  versionCheckHook,
  nix-update-script,
}:

buildGoModule rec {
  pname = "github-mcp-server";
  version = "1.10.1";

  src = fetchFromGitHub {
    owner = "github";
    repo = "github-mcp-server";
    tag = "v${version}";
    hash = "sha256-9521Cx4+xE5QFfD+ny9k/uHI9rU5RiC3SGyhU3hMCYY=";
  };

  vendorHash = "sha256-tNAC2tSmfTuT4OZmq7vrG2j5njJaL1NyN+/IjYegp60=";

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
