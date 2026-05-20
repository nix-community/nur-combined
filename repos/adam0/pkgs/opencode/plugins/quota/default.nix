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
  version = "3.4.0-unstable-2026-05-20";

  src = fetchFromGitHub {
    owner = "slkiser";
    repo = "opencode-${pname}";
    rev = "2aff077a5442f29806cb6fa5e6a8826e1306b95c";
    hash = "sha256-QrjmU96FbLAAl6HRTZyX8ZhHH3b2Qb8dji7LdI27iv4=";
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
