{
  buildNpmPackage,
  fetchFromGitHub,
  lib,
  nix-update-script,
  pi-coding-agent,
}:
buildNpmPackage (finalAttrs: {
  pname = "pi-acp";
  version = "0.0.33";
  src = fetchFromGitHub {
    owner = "svkozak";
    repo = "pi-acp";
    rev = "v${finalAttrs.version}";
    hash = "sha256-fENOOdooi4XbIDjcr02q8qzUCzdo2IW/Bca43SawZ44=";
  };

  npmDepsHash = "sha256-/fX79XucKojL/6gZbK5eizEfrXso8rlTgiHfJffmDuY=";

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "ACP adapter for pi coding agent";
    homepage = "https://github.com/svkozak/pi-acp";
    license = lib.licenses.mit;
    inherit (pi-coding-agent.meta) platforms;
    mainProgram = "pi-acp";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
