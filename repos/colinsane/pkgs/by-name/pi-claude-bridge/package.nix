{
  fetchFromGitHub,
  lib,
  mkPiExtension,
  nix-update-script,
}:
mkPiExtension (finalAttrs: {
  pname = "pi-claude-bridge";
  version = "0.9.3";

  src = fetchFromGitHub {
    owner = "elidickinson";
    repo = "pi-claude-bridge";
    rev = "v${finalAttrs.version}";
    hash = "sha256-2P81N6xWuvJdB3w7egU8QNguXWkOyyRUDePveXY7p0c=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-jMGqITrnMq+g++57m+F/JVlEFF/HvE60gHuSds8nOAU=";

  dontNpmBuild = true;  # package.json defines no build script

  passthru.updateScript = nix-update-script {};

  meta = {
    description = "Pi extension that uses Claude Code (via Agent SDK) as a model provider and adds an AskClaude tool";
    homepage = "https://github.com/elidickinson/pi-claude-bridge";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ colinsane ];
  };
})
