{
  fetchFromGitHub,
  lib,
  mkPiExtension,
  nix-update-script,
}:
mkPiExtension (finalAttrs: {
  pname = "pi-codex-goal";
  version = "0.7.10";

  src = fetchFromGitHub {
    owner = "fitchmultz";
    repo = "pi-codex-goal";
    tag = "v${finalAttrs.version}";
    hash = "sha256-B9hDNVFE7D04h63BzOja0lAcUvKDu8wX80silUJx0+0=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-DggTu0Xcj0kHy5Qpf2U2D8lEevmmoVAWIxPmEU7NwYs=";

  dontNpmBuild = true; # package.json defines no build script

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Codex-style goal tracking and continuation for pi.";
    homepage = "https://github.com/fitchmultz/pi-codex-goal";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ colinsane ];
    platforms = lib.platforms.linux;
  };
})
