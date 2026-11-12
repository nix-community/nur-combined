{
  fetchFromGitHub,
  lib,
  mkPiExtension,
  nix-update-script,
}:
mkPiExtension (finalAttrs: {
  pname = "pi-codex-goal";
  version = "0.7.8";

  src = fetchFromGitHub {
    owner = "fitchmultz";
    repo = "pi-codex-goal";
    tag = "v${finalAttrs.version}";
    hash = "sha256-7vEkiLl8lf8tUtOugz1v34U6AjfNpw37i+wVg0N3cGY=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-O/jCLR9IbAeAH0ufxk37swONUkcPfWizIEk5Mv+AbCk=";

  dontNpmBuild = true;  # package.json defines no build script

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Codex-style goal tracking and continuation for pi.";
    homepage = "https://github.com/fitchmultz/pi-codex-goal";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ colinsane ];
  };
})
