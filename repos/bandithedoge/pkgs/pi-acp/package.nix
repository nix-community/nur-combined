{
  buildNpmPackage,
  fetchFromGitHub,
  lib,
  nix-update-script,
  pi-coding-agent,
}:
buildNpmPackage (finalAttrs: {
  pname = "pi-acp";
  version = "0.0.34";
  src = fetchFromGitHub {
    owner = "svkozak";
    repo = "pi-acp";
    rev = "v${finalAttrs.version}";
    hash = "sha256-QRwxOtTZOY+Np3PkAoy2o2PrUzEqjItM/372sCPlSMo=";
  };

  npmDepsHash = "sha256-BvLNtFfp1cMVjzWcMRSdhTqiJrTfbFoUbWkkPW9200o=";

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
