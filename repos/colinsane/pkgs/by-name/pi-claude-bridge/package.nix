{
  fetchFromGitHub,
  lib,
  mkPiExtension,
  nix-update-script,
}:
mkPiExtension (finalAttrs: {
  pname = "pi-claude-bridge";
  version = "0.13.0";

  src = fetchFromGitHub {
    owner = "elidickinson";
    repo = "pi-claude-bridge";
    rev = "v${finalAttrs.version}";
    hash = "sha256-y7AU77cK1S1poglQA3UmnR8kul3LO3HB8dft5uJ+eMU=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-OVR0IV3RJNHpZt41Wnf8HPkrLs5BW5zG3hxacJsH9hg=";

  dontNpmBuild = true; # package.json defines no build script

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Pi extension that uses Claude Code (via Agent SDK) as a model provider and adds an AskClaude tool";
    homepage = "https://github.com/elidickinson/pi-claude-bridge";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ colinsane ];
    platforms = lib.platforms.linux;
  };
})
