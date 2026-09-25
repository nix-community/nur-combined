{
  fetchFromGitHub,
  fetchPnpmDeps,
  lib,
  mkPiExtension,
  nix-update-script,
  pnpm,
  pnpmConfigHook,
}:
mkPiExtension (finalAttrs: {
  pname = "pi-tool-repair";
  version = "0.3.2";

  src = fetchFromGitHub {
    owner = "monotykamary";
    repo = "pi-tool-repair";
    tag = "v${finalAttrs.version}";
    hash = "sha256-7cMM/hp3DB5URkJCzEsTS/oQMOkzAEgeRkk6XcGTDTs=";
  };

  # XXX(2026-09-23): the lockfile pins 0.85.1 even as package.json specifies 0.86.0.
  # downgrade the lockfile because that's easier.
  postPatch = ''
    substituteInPlace package.json --replace-fail \
      '"@earendil-works/pi-coding-agent": "0.86.0"' \
      '"@earendil-works/pi-coding-agent": "0.85.1"'
  '';

  npmDeps = null;
  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src postPatch;
    inherit pnpm;
    fetcherVersion = 4;
    hash = "sha256-GZANtpa3CW2PCxvwaiPowjTVrxOLa8x6LwKBHJbMdP4=";
  };
  npmConfigHook = pnpmConfigHook;

  nativeBuildInputs = [
    pnpm
  ];

  dontNpmBuild = true;  # no build action in package.json
  dontNpmPrune = true;

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--custom-dep=pnpmDeps" ];
  };

  meta = {
    description = "Validate-then-repair Pi extension for malformed LLM tool calls";
    homepage = "https://github.com/monotykamary/pi-tool-repair";
    maintainers = with lib.maintainers; [ colinsane ];
    license = lib.licenses.mit;
  };
})
