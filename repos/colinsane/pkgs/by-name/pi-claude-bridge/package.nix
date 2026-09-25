{
  fetchFromGitHub,
  lib,
  mkPiExtension,
  nix-update-script,
}:
mkPiExtension (finalAttrs: {
  pname = "pi-claude-bridge";
  version = "0.8.0-unstable-2026-09-23";

  src = fetchFromGitHub {
    owner = "elidickinson";
    repo = "pi-claude-bridge";
    rev = "227f5eb4450a070dfbc083a7fe75b8b35366b941";
    hash = "sha256-tJFAMykelEeQC0Pq1UxN6ZcB36jO6VsM3A0ThUKaVJ4=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-ifMMEtbSdCZqK19gKQJpEfp359w4pJSeznKKQGk1gGU=";

  dontNpmBuild = true;  # package.json defines no build script

  passthru.updateScript = nix-update-script {};

  meta = {
    description = "Pi extension that uses Claude Code (via Agent SDK) as a model provider and adds an AskClaude tool";
    homepage = "https://github.com/elidickinson/pi-claude-bridge";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ colinsane ];
  };
})
