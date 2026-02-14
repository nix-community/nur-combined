{
  lib,
  fetchFromGitHub,
  mkOpencodePlugin,
}:
mkOpencodePlugin rec {
  pname = "cc-safety-net";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "kenryu42";
    repo = "claude-code-safety-net";
    rev = "v${version}";
    hash = "sha256-7KlV5Ni/nnwAsy+PFHT0CgvamLpC8upWM5pyuplk56s=";
  };

  dependencyHash = null;

  meta = {
    description = "OpenCode plugin that blocks destructive git and filesystem commands";
    homepage = "https://github.com/kenryu42/claude-code-safety-net";
    license = lib.licenses.mit;
  };
}
