{
  fetchFromGitHub,
  lib,
  mkPiExtension,
  nix-update-script,
}:
mkPiExtension (finalAttrs: {
  pname = "pi-claude-bridge";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "elidickinson";
    repo = "pi-claude-bridge";
    tag = "v${finalAttrs.version}";
    hash = "sha256-L9aczhKDeXbq5CKFLMb68Oa1J0RzjFtPzucma+NBlTk=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-Ls/0DDs0vEdARVh1ZzcDtKGPydMm2UKmEvZH9VFKQvQ=";

  dontNpmBuild = true;  # package.json defines no build script

  passthru.updateScript = nix-update-script {};

  meta = {
    description = "Pi extension that uses Claude Code (via Agent SDK) as a model provider and adds an AskClaude tool";
    homepage = "https://github.com/elidickinson/pi-claude-bridge";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ colinsane ];
  };
})
