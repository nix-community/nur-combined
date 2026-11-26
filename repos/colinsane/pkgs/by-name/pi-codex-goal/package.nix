{
  fetchFromGitHub,
  lib,
  mkPiExtension,
  nix-update-script,
}:
mkPiExtension (finalAttrs: {
  pname = "pi-codex-goal";
  version = "0.7.11";

  src = fetchFromGitHub {
    owner = "fitchmultz";
    repo = "pi-codex-goal";
    tag = "v${finalAttrs.version}";
    hash = "sha256-VrGotFJBUYbvLJZhKUairmEK70tTyrRjPZzXP2UOkhA=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-jC5c83+7jGdfk3tQ8BtCKWD93Zys8jItDlgIx6JR3N0=";

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
