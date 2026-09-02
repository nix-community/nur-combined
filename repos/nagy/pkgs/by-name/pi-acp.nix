{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  nodejs_22,
}:

buildNpmPackage (finalAttrs: {
  pname = "pi-acp";
  version = "0.0.33";

  src = fetchFromGitHub {
    owner = "svkozak";
    repo = "pi-acp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-fENOOdooi4XbIDjcr02q8qzUCzdo2IW/Bca43SawZ44=";
  };

  npmDepsHash = "sha256-/fX79XucKojL/6gZbK5eizEfrXso8rlTgiHfJffmDuY=";

  nodejs = nodejs_22;

  meta = {
    description = "ACP (Agent Client Protocol) adapter for the pi coding agent";
    homepage = "https://github.com/svkozak/pi-acp";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "pi-acp";
  };
})
