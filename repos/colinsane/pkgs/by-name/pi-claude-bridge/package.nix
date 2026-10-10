{
  fetchFromGitHub,
  lib,
  mkPiExtension,
  nix-update-script,
}:
mkPiExtension (finalAttrs: {
  pname = "pi-claude-bridge";
  version = "0.9.2";

  src = fetchFromGitHub {
    owner = "elidickinson";
    repo = "pi-claude-bridge";
    rev = "v${finalAttrs.version}";
    hash = "sha256-ri1KD0H5Nbt8lAMHbMLVf7dwaoHNbTJfhEuF4Y8lFF8=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-tXK1hZvQ6Z63uawMZXodOLXO3X597EyCaT98NgNweAI=";

  dontNpmBuild = true;  # package.json defines no build script

  passthru.updateScript = nix-update-script {};

  meta = {
    description = "Pi extension that uses Claude Code (via Agent SDK) as a model provider and adds an AskClaude tool";
    homepage = "https://github.com/elidickinson/pi-claude-bridge";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ colinsane ];
  };
})
