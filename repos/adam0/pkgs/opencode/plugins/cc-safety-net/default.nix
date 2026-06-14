{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  mkOpencodePlugin,
  # keep-sorted end
}:
mkOpencodePlugin rec {
  pname = "cc-safety-net";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "kenryu42";
    repo = "claude-code-safety-net";
    rev = "v${version}";
    hash = "sha256-aGswPlKZEb+WlobJZA5ePblc8FDRCHYXnO9iW3dxG6w=";
  };

  dependencyHash = null;

  meta = {
    # keep-sorted start
    description = "A coding agent hook that acts as a safety net";
    homepage = "https://github.com/kenryu42/claude-code-safety-net";
    license = lib.licenses.mit;
    # keep-sorted end
  };
}
