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
  version = "0.2.5";

  src = fetchFromGitHub {
    owner = "monotykamary";
    repo = "pi-tool-repair";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+Xz7QsU2K/r7ePk9EW7hR550Qr75G9JbvmZWiJ37RPM=";
  };

  npmDeps = null;
  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 4;
    hash = "sha256-9NQOj+xuMEItc9LlBv85Z49bvIz2FQYBs9bLJJ6Gti8=";
  };
  npmConfigHook = pnpmConfigHook;

  nativeBuildInputs = [
    pnpm
  ];

  dontNpmBuild = true;  # no build action in package.json
  dontNpmPrune = true;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Validate-then-repair Pi extension for malformed LLM tool calls";
    homepage = "https://github.com/monotykamary/pi-tool-repair";
    maintainers = with lib.maintainers; [ colinsane ];
    license = lib.licenses.mit;
  };
})
