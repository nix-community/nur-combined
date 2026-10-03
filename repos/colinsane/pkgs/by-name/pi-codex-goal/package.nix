{
  fetchFromGitHub,
  lib,
  mkPiExtension,
  nix-update-script,
}:
mkPiExtension (finalAttrs: {
  pname = "pi-codex-goal";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "fitchmultz";
    repo = "pi-codex-goal";
    tag = "v${finalAttrs.version}";
    hash = "sha256-gGhwq5pGsQd2T+oeh6m1VzcEhDWmpJpzrxcbGQakcv4=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-tRjaqSoYUZBAdj6ID3UmQFxHsLODMI9jCFeaPA88ywc=";

  dontNpmBuild = true;  # package.json defines no build script

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Codex-style goal tracking and continuation for pi.";
    homepage = "https://github.com/fitchmultz/pi-codex-goal";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ colinsane ];
  };
})
