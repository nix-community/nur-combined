{
  fetchFromGitHub,
  gitUpdater,
  lib,
  stdenv,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "pi-tool-repair";
  version = "0.1.8";

  src = fetchFromGitHub {
    owner = "monotykamary";
    repo = "pi-tool-repair";
    tag = "v${finalAttrs.version}";
    hash = "sha256-B98sZ5pbp2tSXu1qz46IUlY92ingxQbhQsBF171WNyk=";
  };

  installPhase = ''
    runHook preInstall
    cp -R . $out
    runHook postInstall
  '';

  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
  };

  meta = {
    description = "Validate-then-repair Pi extension for malformed LLM tool calls";
    homepage = "https://github.com/monotykamary/pi-tool-repair";
    maintainers = with lib.maintainers; [ colinsane ];
    license = lib.licenses.mit;
  };
})
