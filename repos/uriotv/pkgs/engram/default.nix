{
  lib,
  buildGoModule,
  fetchFromGitHub,
  git,
}:

buildGoModule (finalAttrs: {
  pname = "engram";
  version = "3.7.2";

  src = fetchFromGitHub {
    owner = "Gentleman-Programming";
    repo = "engram";
    tag = "v${finalAttrs.version}";
    hash = "sha256-8vychLARVy7Ry+7hXx+NxnUR0KIUC5nJA+1XFduDB/M=";
  };

  # The repository also carries unrelated tooling (release helpers, contract
  # generators, plugin test servers); only the agent binary is packaged.
  # Upstream releases are static (no cgo); keep that to avoid a glibc dependency.
  env.CGO_ENABLED = 0;

  subPackages = [ "cmd/engram" ];
  proxyVendor = true;
  vendorHash = "sha256-uNoFAUJfu3SFU9OqT1AJvHKKN6t6oPo6nC6GEbYhYJs=";

  # The command tests drive a real repository (project detection), so they need
  # git in PATH like upstream's CI.
  nativeCheckInputs = [ git ];

  # Reported by `engram version`; upstream's goreleaser sets the same variable.
  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  meta = {
    description = "Persistent memory system for AI coding agents (SQLite + FTS5, MCP server, HTTP API, CLI)";
    homepage = "https://github.com/Gentleman-Programming/engram";
    changelog = "https://github.com/Gentleman-Programming/engram/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "engram";
    platforms = lib.platforms.linux;
  };
})
