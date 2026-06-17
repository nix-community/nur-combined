{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  mkOpencodePlugin,
  nodejs,
  typescript,
  # keep-sorted end
}:
mkOpencodePlugin rec {
  pname = "quota";
  version = "3.10.1-unstable-2026-06-16";

  src = fetchFromGitHub {
    owner = "slkiser";
    repo = "opencode-${pname}";
    rev = "4ec8a88023152f46540e61f80108aedb675b88c4";
    hash = "sha256-5cCbFC/T43o2Oc0klZWjV/oAG+sp9qrDZ7IeLt/a4/U=";
  };

  dependencyHash = "sha256-OXqLHS8zAJNHHFPIHlfxNvDp2Uy/yfOdWGOYS2IGqU0=";
  dependencyInstallCommand = "BUN_CONFIG_SKIP_SAVE_LOCKFILE=1 bun install --no-cache --ignore-scripts";

  nativeBuildInputs = [
    nodejs
    typescript
  ];

  buildCommand = "tsc && node scripts/copy-data.mjs && node scripts/prepare-tui-dist.mjs";

  meta = {
    # keep-sorted start
    description = "OpenCode plugin for quota, usage, and token visibility.";
    homepage = "https://github.com/slkiser/opencode-quota";
    license = lib.licenses.mit;
    # keep-sorted end
  };
}
