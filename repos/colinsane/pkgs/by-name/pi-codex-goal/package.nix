{
  fetchFromGitHub,
  lib,
  mkPiExtension,
  nix-update-script,
}:
mkPiExtension (finalAttrs: {
  pname = "pi-codex-goal";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "fitchmultz";
    repo = "pi-codex-goal";
    tag = "v${finalAttrs.version}";
    hash = "sha256-YFz4P8ZMgxsqRqPGcbDyzvkVswTNRZ4ZiA8FbhBVtlg=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-HHabvevD+KUpnYxmD38W6kw69uotTXdb6gvqRuhyLCk=";

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Codex-style goal tracking and continuation for pi.";
    homepage = "https://github.com/fitchmultz/pi-codex-goal";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ colinsane ];
  };
})
