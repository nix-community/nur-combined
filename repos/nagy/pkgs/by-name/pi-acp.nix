{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  nodejs_22,
}:

buildNpmPackage (finalAttrs: {
  pname = "pi-acp";
  version = "0.0.34";

  src = fetchFromGitHub {
    owner = "svkozak";
    repo = "pi-acp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-QRwxOtTZOY+Np3PkAoy2o2PrUzEqjItM/372sCPlSMo=";
  };

  npmDepsHash = "sha256-BvLNtFfp1cMVjzWcMRSdhTqiJrTfbFoUbWkkPW9200o=";

  nodejs = nodejs_22;

  meta = {
    description = "ACP (Agent Client Protocol) adapter for the pi coding agent";
    homepage = "https://github.com/svkozak/pi-acp";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "pi-acp";
  };
})
