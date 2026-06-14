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
  version = "3.8.8-unstable-2026-06-14";

  src = fetchFromGitHub {
    owner = "slkiser";
    repo = "opencode-${pname}";
    rev = "ad84a490e0c75e93c918c6a311f920255265a829";
    hash = "sha256-OQAxFGFpRQXRc4tc0bFZNnzcwcUzQuNE0cGpKV5vtDk=";
  };

  dependencyHash = "sha256-+ovDgEx5QI0ZooWoaOr/EAwo7qp6YGfw6DAPN+6mQuI=";
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
