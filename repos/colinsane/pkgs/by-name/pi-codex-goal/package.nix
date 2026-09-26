{
  fetchFromGitHub,
  lib,
  mkPiExtension,
  nix-update-script,
}:
mkPiExtension (finalAttrs: {
  pname = "pi-codex-goal";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "fitchmultz";
    repo = "pi-codex-goal";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9jkEFwvGJeVqQAUmpmTCPxUZ9dv1WXwDId+ZJmnHnek=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-6Q8wviqES5APhQdll3xi4UL1LMOdB7FpqJk1071cSD4=";

  dontNpmBuild = true;  # package.json defines no build script

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Codex-style goal tracking and continuation for pi.";
    homepage = "https://github.com/fitchmultz/pi-codex-goal";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ colinsane ];
  };
})
