{
  lib,
  fetchFromGitHub,
  mkOpencodePlugin,
}:
mkOpencodePlugin rec {
  pname = "cc-safety-net";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "kenryu42";
    repo = "claude-code-safety-net";
    rev = "v${version}";
    hash = "sha256-xgXWtSnpHzVwwDeMqWiWOy3wIFsnNcb9X9Op8z4P2bc=";
  };

  dependencyHash = null;

  meta = {
    description = "OpenCode plugin that blocks destructive git and filesystem commands";
    homepage = "https://github.com/kenryu42/claude-code-safety-net";
    license = lib.licenses.mit;
  };
}
