{
  fetchFromGitHub,
  lib,
  mkPiExtension,
  nix-update-script,
}:
mkPiExtension (finalAttrs: {
  pname = "pi-codex-goal";
  version = "0.7.9";

  src = fetchFromGitHub {
    owner = "fitchmultz";
    repo = "pi-codex-goal";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Fxn59toCGu4TJamWDmuOMDuGLGeAc2PDz3rxkgQeoz8=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-M3Z70OS4K391f/6bAIA/FrV6iUOb5W15LjJP329xgi0=";

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
