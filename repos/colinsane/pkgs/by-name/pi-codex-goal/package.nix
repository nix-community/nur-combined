{
  fetchFromGitHub,
  lib,
  mkPiExtension,
  nix-update-script,
}:
mkPiExtension (finalAttrs: {
  pname = "pi-codex-goal";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "fitchmultz";
    repo = "pi-codex-goal";
    tag = "v${finalAttrs.version}";
    hash = "sha256-F/I3tlCYiNB+VrvVymoBQdbfZxMZcvqp1/ymZPRwVgM=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-NE9kKnGs7bue67skFwZTFcRjdPd0VGNCirtXesZvYZM=";

  patches = [
    ./budget.patch
  ];

  dontNpmBuild = true;  # package.json omits a build script

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Codex-style goal tracking and continuation for pi.";
    homepage = "https://github.com/fitchmultz/pi-codex-goal";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ colinsane ];
  };
})
