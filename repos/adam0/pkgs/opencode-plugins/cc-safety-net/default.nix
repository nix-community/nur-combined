{
  lib,
  fetchFromGitHub,
  mkOpencodePlugin,
}:
mkOpencodePlugin rec {
  pname = "cc-safety-net";
  version = "0.8.1";

  src = fetchFromGitHub {
    owner = "kenryu42";
    repo = "claude-code-safety-net";
    rev = "v${version}";
    hash = "sha256-Pz97pGaw1AUqi/R8oIL4sOL/Ur3X/NX2XK2qGsxjDeA=";
  };

  dependencyHash = null;

  meta = {
    description = "OpenCode plugin that blocks destructive git and filesystem commands";
    homepage = "https://github.com/kenryu42/claude-code-safety-net";
    license = lib.licenses.mit;
  };
}
