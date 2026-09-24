{
  fetchFromGitHub,
  lib,
  mkPiExtension,
  nix-update-script,
}:
mkPiExtension (finalAttrs: {
  pname = "pi-codex-goal";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "fitchmultz";
    repo = "pi-codex-goal";
    tag = "v${finalAttrs.version}";
    hash = "sha256-snRkjxXkSfCrbjmNO1hr2RAQkv6gVUfJJgvmf9aPUAU=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-Dmj/vpkOcCPkVPllJUQQ3owpcPDLO6F2ylJ3OvaZ4Bk=";

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Codex-style goal tracking and continuation for pi.";
    homepage = "https://github.com/fitchmultz/pi-codex-goal";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ colinsane ];
  };
})
