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
  version = "3.4.0-unstable-2026-05-03";

  src = fetchFromGitHub {
    owner = "slkiser";
    repo = "opencode-${pname}";
    rev = "4b42a6b1d3f1cdf0cf991fb9cc5b932be9b10f15";
    hash = "sha256-rT4icK1uSbyN5Ef5bSQZmNAkxmtFPUxZCBAIOmPz7l4=";
  };

  dependencyHash = "sha256-C5sROCRwV1Hwb4XhUAhQW7xfA4txgkXWxRmJQ5ZTgKQ=";
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
