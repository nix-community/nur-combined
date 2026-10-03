{
  fetchFromGitHub,
  lib,
  mkPiExtension,
  nix-update-script,
}:
mkPiExtension (finalAttrs: {
  pname = "pi-claude-bridge";
  version = "0.9.1";

  src = fetchFromGitHub {
    owner = "elidickinson";
    repo = "pi-claude-bridge";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Y3uNnHRrcdc3v9PJepG9W+GjBNmq1V9XW08aeV/UM5U=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-+UzB4qCg40rQmZLi1CsuljJeMPyJmZqUjRkJJ4rpfBA=";

  dontNpmBuild = true;  # package.json defines no build script

  passthru.updateScript = nix-update-script {};

  meta = {
    description = "Pi extension that uses Claude Code (via Agent SDK) as a model provider and adds an AskClaude tool";
    homepage = "https://github.com/elidickinson/pi-claude-bridge";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ colinsane ];
  };
})
