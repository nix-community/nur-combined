{
  fetchFromGitHub,
  lib,
  mkPiExtension,
  nix-update-script,
}:
mkPiExtension (finalAttrs: {
  pname = "pi-claude-bridge";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "elidickinson";
    repo = "pi-claude-bridge";
    rev = "v${finalAttrs.version}";
    hash = "sha256-A1hGf/DrZ3iQvk7K73kQ/NoouqfbGbwNO1a3fsQcJog=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-+xCxXzxsdn2KrNzd290guhLUSWe2sG9nHk6h16aBIcc=";

  dontNpmBuild = true;  # package.json defines no build script

  passthru.updateScript = nix-update-script {};

  meta = {
    description = "Pi extension that uses Claude Code (via Agent SDK) as a model provider and adds an AskClaude tool";
    homepage = "https://github.com/elidickinson/pi-claude-bridge";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ colinsane ];
  };
})
